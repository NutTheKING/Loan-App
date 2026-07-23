import type { LoanProduct } from '@prisma/client';

import type { LoanPolicy } from './loan-policy.js';
import { prisma } from './prisma.js';

export function productToPolicy(product: LoanProduct): LoanPolicy {
  return {
    minimumAmount: Number(product.minimumAmount),
    maximumAmount: Number(product.maximumAmount),
    allowedTerms: product.allowedTerms,
    monthlyInterestRate: Number(product.monthlyInterestRate),
    currency: product.currency,
  };
}

export function serializeLoanProduct(product: LoanProduct) {
  return {
    ...product,
    minimumAmount: Number(product.minimumAmount),
    maximumAmount: Number(product.maximumAmount),
    monthlyInterestRate: Number(product.monthlyInterestRate),
  };
}

export async function getActiveLoanProduct(productId?: string): Promise<LoanProduct | null> {
  if (productId) {
    return prisma.loanProduct.findFirst({ where: { id: productId, isActive: true } });
  }
  return prisma.loanProduct.findFirst({
    where: { isActive: true },
    orderBy: [{ isDefault: 'desc' }, { createdAt: 'asc' }],
  });
}
