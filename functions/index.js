const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();

const db = admin.firestore();

function uniqueTokens(tokens) {
  const unique = new Set();
  for (const token of tokens) {
    if (typeof token === 'string' && token.trim().length > 0) {
      unique.add(token);
    }
  }
  return Array.from(unique);
}

function formatAmount(amount) {
  if (typeof amount !== 'number' || Number.isNaN(amount)) {
    return '';
  }
  const fixed = amount.toFixed(2);
  return fixed.replace(/\.00$/, '');
}

exports.notifyFamilyTransaction = functions.firestore
  .document('budgets/{budgetId}/transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) {
      return null;
    }

    if (data.type && data.type !== 'expense') {
      return null;
    }

    const budgetId = context.params.budgetId;
    const budgetSnap = await db.collection('budgets').doc(budgetId).get();
    if (!budgetSnap.exists) {
      return null;
    }

    const budget = budgetSnap.data() || {};
    if (budget.type !== 'family') {
      return null;
    }

    const memberIds = Array.isArray(budget.memberIds) ? budget.memberIds : [];
    if (memberIds.length === 0) {
      return null;
    }

    const createdByUserId = data.createdByUserId;
    const recipients = memberIds.filter(
      (id) => id && id !== createdByUserId,
    );
    if (recipients.length === 0) {
      return null;
    }

    const users = [];
    for (let i = 0; i < recipients.length; i += 10) {
      const chunk = recipients.slice(i, i + 10);
      const usersSnap = await db
        .collection('users')
        .where(admin.firestore.FieldPath.documentId(), 'in', chunk)
        .get();
      usersSnap.forEach((doc) => users.push({ id: doc.id, ...doc.data() }));
    }

    const tokens = [];
    for (const user of users) {
      if (user.notifyFamilyTransactions === false) {
        continue;
      }
      const userTokens = Array.isArray(user.fcmTokens)
        ? user.fcmTokens
        : [];
      tokens.push(...userTokens);
    }

    const payloadTokens = uniqueTokens(tokens);
    if (payloadTokens.length === 0) {
      return null;
    }

    const categoryName =
      typeof data.categoryName === 'string' && data.categoryName.trim().length > 0
        ? data.categoryName.trim()
        : 'Операция';
    const note =
      typeof data.note === 'string' && data.note.trim().length > 0
        ? data.note.trim()
        : '';
    const amountText = formatAmount(data.amount);
    const currencyCode =
      typeof budget.currencyCode === 'string' && budget.currencyCode
        ? ` ${budget.currencyCode}`
        : '';

    const parts = [];
    if (amountText) {
      parts.push(`${amountText}${currencyCode}`);
    }
    if (note) {
      parts.push(note);
    }

    const body =
      parts.length > 0
        ? `${categoryName} • ${parts.join(' • ')}`
        : categoryName;

    const message = {
      notification: {
        title: 'Новая трата в семье',
        body,
      },
      data: {
        type: 'family_transaction',
        budgetId,
        transactionId: context.params.transactionId,
      },
      tokens: payloadTokens,
    };

    return admin.messaging().sendEachForMulticast(message);
  });
