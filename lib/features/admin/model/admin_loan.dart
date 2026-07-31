class AdminBorrower {
  const AdminBorrower({
    required this.id,
    required this.fullName,
    required this.email,
    this.idNumber,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePhotoUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String? idNumber;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profilePhotoUrl;

  factory AdminBorrower.fromJson(Map<String, dynamic> json) {
    return AdminBorrower(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Unknown customer',
      email: json['email'] as String? ?? '',
      idNumber: json['idNumber'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: DateTime.tryParse('${json['dateOfBirth'] ?? ''}'),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}

class AdminLoanDocument {
  const AdminLoanDocument({
    required this.id,
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.url,
  });

  final String id;
  final String kind;
  final String fileName;
  final String mimeType;
  final String url;

  factory AdminLoanDocument.fromJson(Map<String, dynamic> json) {
    return AdminLoanDocument(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? 'DOCUMENT',
      fileName: json['fileName'] as String? ?? 'document',
      mimeType: json['mimeType'] as String? ?? 'image/png',
      url: json['url'] as String? ?? '',
    );
  }
}

class AdminLoan {
  const AdminLoan({
    required this.id,
    required this.loanNumber,
    required this.status,
    required this.currency,
    required this.principal,
    required this.termMonths,
    required this.monthlyPayment,
    required this.totalRepayment,
    required this.actualName,
    required this.idCardNumber,
    required this.currentJob,
    required this.gender,
    required this.stableIncome,
    required this.loanPurpose,
    required this.currentAddress,
    required this.guarantorName,
    required this.guarantorPhone,
    required this.beneficiaryBank,
    required this.accountName,
    required this.accountNumber,
    required this.createdAt,
    required this.borrower,
    required this.documents,
    this.reviewerNote,
    this.submittedAt,
    this.reviewedAt,
    this.disbursedAt,
    this.informationRequestedAt,
  });

  final String id;
  final String loanNumber;
  final String status;
  final String currency;
  final double principal;
  final int termMonths;
  final double monthlyPayment;
  final double totalRepayment;
  final String actualName;
  final String idCardNumber;
  final String currentJob;
  final String gender;
  final double stableIncome;
  final String loanPurpose;
  final String currentAddress;
  final String guarantorName;
  final String guarantorPhone;
  final String beneficiaryBank;
  final String accountName;
  final String accountNumber;
  final DateTime createdAt;
  final AdminBorrower borrower;
  final List<AdminLoanDocument> documents;
  final String? reviewerNote;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime? disbursedAt;
  final DateTime? informationRequestedAt;

  bool get isPending => status == 'PENDING';

  factory AdminLoan.fromJson(Map<String, dynamic> json) {
    final borrowerJson = json['borrower'];
    final documentJson = json['documents'];
    return AdminLoan(
      id: json['id'] as String? ?? '',
      loanNumber: json['loanNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      currency: json['currency'] as String? ?? 'PHP',
      principal: _asDouble(json['principal']),
      termMonths: (json['termMonths'] as num?)?.toInt() ?? 0,
      monthlyPayment: _asDouble(json['monthlyPayment']),
      totalRepayment: _asDouble(json['totalRepayment']),
      actualName: json['actualName'] as String? ?? '',
      idCardNumber: json['idCardNumber'] as String? ?? '',
      currentJob: json['currentJob'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      stableIncome: _asDouble(json['stableIncome']),
      loanPurpose: json['loanPurpose'] as String? ?? '',
      currentAddress: json['currentAddress'] as String? ?? '',
      guarantorName: json['guarantorName'] as String? ?? '',
      guarantorPhone: json['guarantorPhone'] as String? ?? '',
      beneficiaryBank: json['beneficiaryBank'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      borrower: borrowerJson is Map
          ? AdminBorrower.fromJson(Map<String, dynamic>.from(borrowerJson))
          : AdminBorrower(
              id: json['borrowerId'] as String? ?? '',
              fullName: json['actualName'] as String? ?? 'Unknown customer',
              email: '',
            ),
      documents: documentJson is List
          ? documentJson
                .whereType<Map>()
                .map(
                  (document) => AdminLoanDocument.fromJson(
                    Map<String, dynamic>.from(document),
                  ),
                )
                .toList()
          : const [],
      reviewerNote: json['reviewerNote'] as String?,
      submittedAt: DateTime.tryParse('${json['submittedAt'] ?? ''}'),
      reviewedAt: DateTime.tryParse('${json['reviewedAt'] ?? ''}'),
      disbursedAt: DateTime.tryParse('${json['disbursedAt'] ?? ''}'),
      informationRequestedAt: DateTime.tryParse(
        '${json['informationRequestedAt'] ?? ''}',
      ),
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminLoanProduct {
  const AdminLoanProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.currency,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.monthlyInterestRate,
    required this.allowedTerms,
    required this.repaymentFrequency,
    required this.isActive,
    required this.isDefault,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String currency;
  final double minimumAmount;
  final double maximumAmount;
  final double monthlyInterestRate;
  final List<int> allowedTerms;
  final String repaymentFrequency;
  final bool isActive;
  final bool isDefault;

  factory AdminLoanProduct.fromJson(Map<String, dynamic> json) {
    return AdminLoanProduct(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      currency: json['currency'] as String? ?? 'PHP',
      minimumAmount: AdminLoan._asDouble(json['minimumAmount']),
      maximumAmount: AdminLoan._asDouble(json['maximumAmount']),
      monthlyInterestRate: AdminLoan._asDouble(json['monthlyInterestRate']),
      allowedTerms: (json['allowedTerms'] as List? ?? const [])
          .whereType<num>()
          .map((term) => term.toInt())
          .toList(),
      repaymentFrequency: json['repaymentFrequency'] as String? ?? 'MONTHLY',
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'description': description,
    'currency': currency,
    'minimumAmount': minimumAmount,
    'maximumAmount': maximumAmount,
    'monthlyInterestRate': monthlyInterestRate,
    'allowedTerms': allowedTerms,
    'repaymentFrequency': repaymentFrequency,
    'isActive': isActive,
    'isDefault': isDefault,
  };
}

class AdminBranch {
  const AdminBranch({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
    this.email,
    this.managerName,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? managerName;
  final bool isActive;

  factory AdminBranch.fromJson(Map<String, dynamic> json) {
    return AdminBranch(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      managerName: json['managerName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'address': address,
    'phone': phone,
    'email': email,
    'managerName': managerName,
    'isActive': isActive,
  };
}

class AdminPermission {
  const AdminPermission({
    required this.key,
    required this.name,
    required this.description,
    required this.category,
    required this.sortOrder,
    required this.defaultRoles,
  });

  final String key;
  final String name;
  final String description;
  final String category;
  final int sortOrder;
  final List<String> defaultRoles;

  factory AdminPermission.fromJson(Map<String, dynamic> json) =>
      AdminPermission(
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        defaultRoles: (json['defaultRoles'] as List? ?? const [])
            .whereType<String>()
            .toList(),
      );
}

class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isActive,
    required this.isOnline,
    required this.loanCount,
    required this.transactionCount,
    required this.createdAt,
    this.idNumber,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePhotoUrl,
    this.lastLoginAt,
    this.lastSeenAt,
    this.password,
  });

  final String id;
  final String email;
  final String fullName;
  final String? idNumber;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profilePhotoUrl;
  final bool isActive;
  final bool isOnline;
  final int loanCount;
  final int transactionCount;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastSeenAt;
  final String? password;

  String get presenceStatus => isOnline ? 'Online' : 'Offline';

  factory AdminCustomer.fromJson(Map<String, dynamic> json) {
    final counts = json['_count'] is Map
        ? Map<String, dynamic>.from(json['_count'] as Map)
        : const <String, dynamic>{};
    return AdminCustomer(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      idNumber: json['idNumber'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: DateTime.tryParse('${json['dateOfBirth'] ?? ''}'),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? false,
      loanCount: (counts['loans'] as num?)?.toInt() ?? 0,
      transactionCount: (counts['transactions'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
      lastSeenAt: DateTime.tryParse(json['lastSeenAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'fullName': fullName,
    'idNumber': idNumber,
    'phone': phone,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender,
    'address': address,
    'profilePhotoUrl': profilePhotoUrl,
    'isActive': isActive,
    if (password != null && password!.isNotEmpty) 'password': password,
  };
}

class AdminTransaction {
  const AdminTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.description,
    required this.occurredAt,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.loanNumber,
    this.reviewReason,
    this.reviewedAt,
    this.reviewerName,
    this.profilePhotoUrl,
  });

  final String id;
  final String type;
  final String status;
  final double amount;
  final String currency;
  final String description;
  final DateTime occurredAt;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? loanNumber;
  final String? reviewReason;
  final DateTime? reviewedAt;
  final String? reviewerName;
  final String? profilePhotoUrl;

  bool get isPending => status == 'PENDING';
  bool get canDelete => status == 'PENDING' || status == 'REJECTED';

  factory AdminTransaction.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    final loan = json['loan'] is Map
        ? Map<String, dynamic>.from(json['loan'] as Map)
        : const <String, dynamic>{};
    final reviewer = json['reviewedBy'] is Map
        ? Map<String, dynamic>.from(json['reviewedBy'] as Map)
        : const <String, dynamic>{};
    return AdminTransaction(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'DEPOSIT',
      status: json['status'] as String? ?? 'PENDING',
      amount: AdminLoan._asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'PHP',
      description: json['description'] as String? ?? '',
      occurredAt:
          DateTime.tryParse('${json['occurredAt'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      customerId: user['id'] as String? ?? json['userId'] as String? ?? '',
      customerName: user['fullName'] as String? ?? 'Unknown customer',
      customerEmail: user['email'] as String? ?? '',
      loanNumber: loan['loanNumber'] as String?,
      reviewReason: json['reviewReason'] as String?,
      reviewedAt: DateTime.tryParse('${json['reviewedAt'] ?? ''}'),
      reviewerName: reviewer['fullName'] as String?,
      profilePhotoUrl: user['profilePhotoUrl'] as String?,
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.isOnline,
    required this.permissions,
    this.idNumber,
    this.lastLoginAt,
    this.lastSeenAt,
    this.password,
  });

  final String id;
  final String email;
  final String fullName;
  final String? idNumber;
  final String role;
  final bool isActive;
  final bool isOnline;
  final List<String> permissions;
  final DateTime? lastLoginAt;
  final DateTime? lastSeenAt;
  final String? password;

  bool get isBackOffice => role == 'ADMIN' || role == 'STAFF';

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String? ?? '',
    email: json['email'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    idNumber: json['idNumber'] as String?,
    role: json['role'] as String? ?? 'CUSTOMER',
    isActive: json['isActive'] as bool? ?? true,
    isOnline: json['isOnline'] as bool? ?? false,
    permissions: (json['permissions'] as List? ?? const [])
        .whereType<String>()
        .toList(),
    lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
    lastSeenAt: DateTime.tryParse(json['lastSeenAt'] as String? ?? ''),
  );

  Map<String, dynamic> toJson({bool includePermissions = true}) => {
    'email': email,
    'fullName': fullName,
    'idNumber': idNumber,
    'role': role,
    'isActive': isActive,
    if (includePermissions) 'permissionKeys': permissions,
    if (password != null && password!.isNotEmpty) 'password': password,
  };
}
