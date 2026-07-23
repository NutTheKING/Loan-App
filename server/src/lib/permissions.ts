import type { UserRole } from '@prisma/client';

import { prisma } from './prisma.js';

export const Permissions = {
  dashboardView: 'dashboard.view',
  loansRead: 'loans.read',
  loansReview: 'loans.review',
  customersRead: 'customers.read',
  customersManage: 'customers.manage',
  usersManage: 'users.manage',
  permissionsManage: 'permissions.manage',
  productsRead: 'products.read',
  productsManage: 'products.manage',
  repaymentsRead: 'repayments.read',
  transactionsRead: 'transactions.read',
  reportsRead: 'reports.read',
  branchesRead: 'branches.read',
  branchesManage: 'branches.manage',
} as const;

export type PermissionKey = (typeof Permissions)[keyof typeof Permissions];

export async function getEffectivePermissions(userId: string, role: UserRole): Promise<string[]> {
  const [roleAssignments, userAssignments] = await Promise.all([
    prisma.rolePermission.findMany({
      where: { role },
      select: { permission: { select: { key: true } } },
    }),
    prisma.userPermission.findMany({
      where: { userId },
      select: { granted: true, permission: { select: { key: true } } },
    }),
  ]);

  const permissions = new Set(roleAssignments.map((assignment) => assignment.permission.key));
  for (const assignment of userAssignments) {
    if (assignment.granted) {
      permissions.add(assignment.permission.key);
    } else {
      permissions.delete(assignment.permission.key);
    }
  }
  return [...permissions].sort();
}

export async function findUserIdsWithPermission(permissionKey: string): Promise<string[]> {
  const roles = await prisma.rolePermission.findMany({
    where: { permission: { key: permissionKey } },
    select: { role: true },
  });
  const roleValues = roles.map((assignment) => assignment.role);
  const users = await prisma.user.findMany({
    where: {
      isActive: true,
      AND: [
        {
          OR: [
            { role: { in: roleValues } },
            { permissionOverrides: { some: { granted: true, permission: { key: permissionKey } } } },
          ],
        },
        { NOT: { permissionOverrides: { some: { granted: false, permission: { key: permissionKey } } } } },
      ],
    },
    select: { id: true },
  });
  return users.map((user) => user.id);
}
