// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_database.dart';

// ignore_for_file: type=lint
class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _baseCurrencyCodeMeta = const VerificationMeta(
    'baseCurrencyCode',
  );
  @override
  late final GeneratedColumn<String> baseCurrencyCode = GeneratedColumn<String>(
    'base_currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slot,
    id,
    baseCurrencyCode,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('base_currency_code')) {
      context.handle(
        _baseCurrencyCodeMeta,
        baseCurrencyCode.isAcceptableOrUnknown(
          data['base_currency_code']!,
          _baseCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyCodeMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      baseCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency_code'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final int slot;
  final String id;
  final String baseCurrencyCode;
  final int createdAtUtc;
  final int updatedAtUtc;
  const LocalProfile({
    required this.slot,
    required this.id,
    required this.baseCurrencyCode,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    map['id'] = Variable<String>(id);
    map['base_currency_code'] = Variable<String>(baseCurrencyCode);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      slot: Value(slot),
      id: Value(id),
      baseCurrencyCode: Value(baseCurrencyCode),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      slot: serializer.fromJson<int>(json['slot']),
      id: serializer.fromJson<String>(json['id']),
      baseCurrencyCode: serializer.fromJson<String>(json['baseCurrencyCode']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'id': serializer.toJson<String>(id),
      'baseCurrencyCode': serializer.toJson<String>(baseCurrencyCode),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  LocalProfile copyWith({
    int? slot,
    String? id,
    String? baseCurrencyCode,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => LocalProfile(
    slot: slot ?? this.slot,
    id: id ?? this.id,
    baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      slot: data.slot.present ? data.slot.value : this.slot,
      id: data.id.present ? data.id.value : this.id,
      baseCurrencyCode: data.baseCurrencyCode.present
          ? data.baseCurrencyCode.value
          : this.baseCurrencyCode,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('slot: $slot, ')
          ..write('id: $id, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(slot, id, baseCurrencyCode, createdAtUtc, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.slot == this.slot &&
          other.id == this.id &&
          other.baseCurrencyCode == this.baseCurrencyCode &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<int> slot;
  final Value<String> id;
  final Value<String> baseCurrencyCode;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  const LocalProfilesCompanion({
    this.slot = const Value.absent(),
    this.id = const Value.absent(),
    this.baseCurrencyCode = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    this.slot = const Value.absent(),
    required String id,
    required String baseCurrencyCode,
    required int createdAtUtc,
    required int updatedAtUtc,
  }) : id = Value(id),
       baseCurrencyCode = Value(baseCurrencyCode),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<LocalProfile> custom({
    Expression<int>? slot,
    Expression<String>? id,
    Expression<String>? baseCurrencyCode,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (id != null) 'id': id,
      if (baseCurrencyCode != null) 'base_currency_code': baseCurrencyCode,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<int>? slot,
    Value<String>? id,
    Value<String>? baseCurrencyCode,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
  }) {
    return LocalProfilesCompanion(
      slot: slot ?? this.slot,
      id: id ?? this.id,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baseCurrencyCode.present) {
      map['base_currency_code'] = Variable<String>(baseCurrencyCode.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('slot: $slot, ')
          ..write('id: $id, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingMinorUnitsMeta = const VerificationMeta(
    'openingMinorUnits',
  );
  @override
  late final GeneratedColumn<int> openingMinorUnits = GeneratedColumn<int>(
    'opening_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingDateMeta = const VerificationMeta(
    'openingDate',
  );
  @override
  late final GeneratedColumn<String> openingDate = GeneratedColumn<String>(
    'opening_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    kind,
    currencyCode,
    openingMinorUnits,
    openingDate,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('opening_minor_units')) {
      context.handle(
        _openingMinorUnitsMeta,
        openingMinorUnits.isAcceptableOrUnknown(
          data['opening_minor_units']!,
          _openingMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingMinorUnitsMeta);
    }
    if (data.containsKey('opening_date')) {
      context.handle(
        _openingDateMeta,
        openingDate.isAcceptableOrUnknown(
          data['opening_date']!,
          _openingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingDateMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      openingMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_minor_units'],
      )!,
      openingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_date'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String profileId;
  final String name;
  final String kind;
  final String currencyCode;
  final int openingMinorUnits;
  final String openingDate;
  final bool isArchived;
  final int createdAtUtc;
  final int updatedAtUtc;
  const Account({
    required this.id,
    required this.profileId,
    required this.name,
    required this.kind,
    required this.currencyCode,
    required this.openingMinorUnits,
    required this.openingDate,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['currency_code'] = Variable<String>(currencyCode);
    map['opening_minor_units'] = Variable<int>(openingMinorUnits);
    map['opening_date'] = Variable<String>(openingDate);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      kind: Value(kind),
      currencyCode: Value(currencyCode),
      openingMinorUnits: Value(openingMinorUnits),
      openingDate: Value(openingDate),
      isArchived: Value(isArchived),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      openingMinorUnits: serializer.fromJson<int>(json['openingMinorUnits']),
      openingDate: serializer.fromJson<String>(json['openingDate']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'openingMinorUnits': serializer.toJson<int>(openingMinorUnits),
      'openingDate': serializer.toJson<String>(openingDate),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  Account copyWith({
    String? id,
    String? profileId,
    String? name,
    String? kind,
    String? currencyCode,
    int? openingMinorUnits,
    String? openingDate,
    bool? isArchived,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => Account(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    currencyCode: currencyCode ?? this.currencyCode,
    openingMinorUnits: openingMinorUnits ?? this.openingMinorUnits,
    openingDate: openingDate ?? this.openingDate,
    isArchived: isArchived ?? this.isArchived,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      openingMinorUnits: data.openingMinorUnits.present
          ? data.openingMinorUnits.value
          : this.openingMinorUnits,
      openingDate: data.openingDate.present
          ? data.openingDate.value
          : this.openingDate,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('openingMinorUnits: $openingMinorUnits, ')
          ..write('openingDate: $openingDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    kind,
    currencyCode,
    openingMinorUnits,
    openingDate,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currencyCode == this.currencyCode &&
          other.openingMinorUnits == this.openingMinorUnits &&
          other.openingDate == this.openingDate &&
          other.isArchived == this.isArchived &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> currencyCode;
  final Value<int> openingMinorUnits;
  final Value<String> openingDate;
  final Value<bool> isArchived;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.openingMinorUnits = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    required String kind,
    required String currencyCode,
    required int openingMinorUnits,
    required String openingDate,
    this.isArchived = const Value.absent(),
    required int createdAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       kind = Value(kind),
       currencyCode = Value(currencyCode),
       openingMinorUnits = Value(openingMinorUnits),
       openingDate = Value(openingDate),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currencyCode,
    Expression<int>? openingMinorUnits,
    Expression<String>? openingDate,
    Expression<bool>? isArchived,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (openingMinorUnits != null) 'opening_minor_units': openingMinorUnits,
      if (openingDate != null) 'opening_date': openingDate,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? currencyCode,
    Value<int>? openingMinorUnits,
    Value<String>? openingDate,
    Value<bool>? isArchived,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currencyCode: currencyCode ?? this.currencyCode,
      openingMinorUnits: openingMinorUnits ?? this.openingMinorUnits,
      openingDate: openingDate ?? this.openingDate,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (openingMinorUnits.present) {
      map['opening_minor_units'] = Variable<int>(openingMinorUnits.value);
    }
    if (openingDate.present) {
      map['opening_date'] = Variable<String>(openingDate.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('openingMinorUnits: $openingMinorUnits, ')
          ..write('openingDate: $openingDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    kind,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String profileId;
  final String name;
  final String kind;
  final bool isArchived;
  final int createdAtUtc;
  final int updatedAtUtc;
  const Category({
    required this.id,
    required this.profileId,
    required this.name,
    required this.kind,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      kind: Value(kind),
      isArchived: Value(isArchived),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  Category copyWith({
    String? id,
    String? profileId,
    String? name,
    String? kind,
    bool? isArchived,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => Category(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    isArchived: isArchived ?? this.isArchived,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    kind,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.isArchived == this.isArchived &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> kind;
  final Value<bool> isArchived;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    required String kind,
    this.isArchived = const Value.absent(),
    required int createdAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       kind = Value(kind),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<bool>? isArchived,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? kind,
    Value<bool>? isArchived,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    description,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String profileId;
  final String name;
  final String? description;
  final bool isArchived;
  final int createdAtUtc;
  final int updatedAtUtc;
  const Project({
    required this.id,
    required this.profileId,
    required this.name,
    this.description,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isArchived: Value(isArchived),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  Project copyWith({
    String? id,
    String? profileId,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isArchived,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => Project(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isArchived: isArchived ?? this.isArchived,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    description,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.description == this.description &&
          other.isArchived == this.isArchived &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isArchived;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    this.description = const Value.absent(),
    this.isArchived = const Value.absent(),
    required int createdAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isArchived,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isArchived,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _warningThresholdPercentMeta =
      const VerificationMeta('warningThresholdPercent');
  @override
  late final GeneratedColumn<int> warningThresholdPercent =
      GeneratedColumn<int>(
        'warning_threshold_percent',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(80),
      );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    amountMinorUnits,
    currencyCode,
    month,
    categoryId,
    warningThresholdPercent,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('warning_threshold_percent')) {
      context.handle(
        _warningThresholdPercentMeta,
        warningThresholdPercent.isAcceptableOrUnknown(
          data['warning_threshold_percent']!,
          _warningThresholdPercentMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      warningThresholdPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_threshold_percent'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String profileId;
  final String name;
  final int amountMinorUnits;
  final String currencyCode;
  final String month;
  final String? categoryId;
  final int warningThresholdPercent;
  final bool isArchived;
  final int createdAtUtc;
  final int updatedAtUtc;
  const Budget({
    required this.id,
    required this.profileId,
    required this.name,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.month,
    this.categoryId,
    required this.warningThresholdPercent,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['month'] = Variable<String>(month);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['warning_threshold_percent'] = Variable<int>(warningThresholdPercent);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      month: Value(month),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      warningThresholdPercent: Value(warningThresholdPercent),
      isArchived: Value(isArchived),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      month: serializer.fromJson<String>(json['month']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      warningThresholdPercent: serializer.fromJson<int>(
        json['warningThresholdPercent'],
      ),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'month': serializer.toJson<String>(month),
      'categoryId': serializer.toJson<String?>(categoryId),
      'warningThresholdPercent': serializer.toJson<int>(
        warningThresholdPercent,
      ),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  Budget copyWith({
    String? id,
    String? profileId,
    String? name,
    int? amountMinorUnits,
    String? currencyCode,
    String? month,
    Value<String?> categoryId = const Value.absent(),
    int? warningThresholdPercent,
    bool? isArchived,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => Budget(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    month: month ?? this.month,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    warningThresholdPercent:
        warningThresholdPercent ?? this.warningThresholdPercent,
    isArchived: isArchived ?? this.isArchived,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      month: data.month.present ? data.month.value : this.month,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      warningThresholdPercent: data.warningThresholdPercent.present
          ? data.warningThresholdPercent.value
          : this.warningThresholdPercent,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('month: $month, ')
          ..write('categoryId: $categoryId, ')
          ..write('warningThresholdPercent: $warningThresholdPercent, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    amountMinorUnits,
    currencyCode,
    month,
    categoryId,
    warningThresholdPercent,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.month == this.month &&
          other.categoryId == this.categoryId &&
          other.warningThresholdPercent == this.warningThresholdPercent &&
          other.isArchived == this.isArchived &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> month;
  final Value<String?> categoryId;
  final Value<int> warningThresholdPercent;
  final Value<bool> isArchived;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.month = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.warningThresholdPercent = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    required int amountMinorUnits,
    required String currencyCode,
    required String month,
    this.categoryId = const Value.absent(),
    this.warningThresholdPercent = const Value.absent(),
    this.isArchived = const Value.absent(),
    required int createdAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       month = Value(month),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? month,
    Expression<String>? categoryId,
    Expression<int>? warningThresholdPercent,
    Expression<bool>? isArchived,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (month != null) 'month': month,
      if (categoryId != null) 'category_id': categoryId,
      if (warningThresholdPercent != null)
        'warning_threshold_percent': warningThresholdPercent,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? month,
    Value<String?>? categoryId,
    Value<int>? warningThresholdPercent,
    Value<bool>? isArchived,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      month: month ?? this.month,
      categoryId: categoryId ?? this.categoryId,
      warningThresholdPercent:
          warningThresholdPercent ?? this.warningThresholdPercent,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (warningThresholdPercent.present) {
      map['warning_threshold_percent'] = Variable<int>(
        warningThresholdPercent.value,
      );
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('month: $month, ')
          ..write('categoryId: $categoryId, ')
          ..write('warningThresholdPercent: $warningThresholdPercent, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookkeepingTransactionsTable extends BookkeepingTransactions
    with TableInfo<$BookkeepingTransactionsTable, BookkeepingTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookkeepingTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMeta = const VerificationMeta(
    'deletedAtUtc',
  );
  @override
  late final GeneratedColumn<int> deletedAtUtc = GeneratedColumn<int>(
    'deleted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    accountId,
    categoryId,
    projectId,
    kind,
    amountMinorUnits,
    currencyCode,
    businessDate,
    note,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookkeeping_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookkeepingTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('deleted_at_utc')) {
      context.handle(
        _deletedAtUtcMeta,
        deletedAtUtc.isAcceptableOrUnknown(
          data['deleted_at_utc']!,
          _deletedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookkeepingTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookkeepingTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      deletedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc'],
      ),
    );
  }

  @override
  $BookkeepingTransactionsTable createAlias(String alias) {
    return $BookkeepingTransactionsTable(attachedDatabase, alias);
  }
}

class BookkeepingTransaction extends DataClass
    implements Insertable<BookkeepingTransaction> {
  final String id;
  final String profileId;
  final String accountId;
  final String categoryId;
  final String? projectId;
  final String kind;
  final int amountMinorUnits;
  final String currencyCode;
  final String businessDate;
  final String? note;
  final int createdAtUtc;
  final int updatedAtUtc;
  final int? deletedAtUtc;
  const BookkeepingTransaction({
    required this.id,
    required this.profileId,
    required this.accountId,
    required this.categoryId,
    this.projectId,
    required this.kind,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.businessDate,
    this.note,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['account_id'] = Variable<String>(accountId);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['kind'] = Variable<String>(kind);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    if (!nullToAbsent || deletedAtUtc != null) {
      map['deleted_at_utc'] = Variable<int>(deletedAtUtc);
    }
    return map;
  }

  BookkeepingTransactionsCompanion toCompanion(bool nullToAbsent) {
    return BookkeepingTransactionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      accountId: Value(accountId),
      categoryId: Value(categoryId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      kind: Value(kind),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      businessDate: Value(businessDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      deletedAtUtc: deletedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtc),
    );
  }

  factory BookkeepingTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookkeepingTransaction(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
      deletedAtUtc: serializer.fromJson<int?>(json['deletedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'accountId': serializer.toJson<String>(accountId),
      'categoryId': serializer.toJson<String>(categoryId),
      'projectId': serializer.toJson<String?>(projectId),
      'kind': serializer.toJson<String>(kind),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'businessDate': serializer.toJson<String>(businessDate),
      'note': serializer.toJson<String?>(note),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
      'deletedAtUtc': serializer.toJson<int?>(deletedAtUtc),
    };
  }

  BookkeepingTransaction copyWith({
    String? id,
    String? profileId,
    String? accountId,
    String? categoryId,
    Value<String?> projectId = const Value.absent(),
    String? kind,
    int? amountMinorUnits,
    String? currencyCode,
    String? businessDate,
    Value<String?> note = const Value.absent(),
    int? createdAtUtc,
    int? updatedAtUtc,
    Value<int?> deletedAtUtc = const Value.absent(),
  }) => BookkeepingTransaction(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    projectId: projectId.present ? projectId.value : this.projectId,
    kind: kind ?? this.kind,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    businessDate: businessDate ?? this.businessDate,
    note: note.present ? note.value : this.note,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    deletedAtUtc: deletedAtUtc.present ? deletedAtUtc.value : this.deletedAtUtc,
  );
  BookkeepingTransaction copyWithCompanion(
    BookkeepingTransactionsCompanion data,
  ) {
    return BookkeepingTransaction(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      deletedAtUtc: data.deletedAtUtc.present
          ? data.deletedAtUtc.value
          : this.deletedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookkeepingTransaction(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('businessDate: $businessDate, ')
          ..write('note: $note, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    accountId,
    categoryId,
    projectId,
    kind,
    amountMinorUnits,
    currencyCode,
    businessDate,
    note,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookkeepingTransaction &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.projectId == this.projectId &&
          other.kind == this.kind &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.businessDate == this.businessDate &&
          other.note == this.note &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.deletedAtUtc == this.deletedAtUtc);
}

class BookkeepingTransactionsCompanion
    extends UpdateCompanion<BookkeepingTransaction> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> accountId;
  final Value<String> categoryId;
  final Value<String?> projectId;
  final Value<String> kind;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> businessDate;
  final Value<String?> note;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int?> deletedAtUtc;
  final Value<int> rowid;
  const BookkeepingTransactionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookkeepingTransactionsCompanion.insert({
    required String id,
    required String profileId,
    required String accountId,
    required String categoryId,
    this.projectId = const Value.absent(),
    required String kind,
    required int amountMinorUnits,
    required String currencyCode,
    required String businessDate,
    this.note = const Value.absent(),
    required int createdAtUtc,
    required int updatedAtUtc,
    this.deletedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       accountId = Value(accountId),
       categoryId = Value(categoryId),
       kind = Value(kind),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       businessDate = Value(businessDate),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<BookkeepingTransaction> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<String>? projectId,
    Expression<String>? kind,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? businessDate,
    Expression<String>? note,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? deletedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (projectId != null) 'project_id': projectId,
      if (kind != null) 'kind': kind,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (businessDate != null) 'business_date': businessDate,
      if (note != null) 'note': note,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (deletedAtUtc != null) 'deleted_at_utc': deletedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookkeepingTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? accountId,
    Value<String>? categoryId,
    Value<String?>? projectId,
    Value<String>? kind,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? businessDate,
    Value<String?>? note,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int?>? deletedAtUtc,
    Value<int>? rowid,
  }) {
    return BookkeepingTransactionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      projectId: projectId ?? this.projectId,
      kind: kind ?? this.kind,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      businessDate: businessDate ?? this.businessDate,
      note: note ?? this.note,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      deletedAtUtc: deletedAtUtc ?? this.deletedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (deletedAtUtc.present) {
      map['deleted_at_utc'] = Variable<int>(deletedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookkeepingTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('businessDate: $businessDate, ')
          ..write('note: $note, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, Transfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _sourceAccountIdMeta = const VerificationMeta(
    'sourceAccountId',
  );
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
    'source_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id)',
        ),
      );
  static const VerificationMeta _sourceMinorUnitsMeta = const VerificationMeta(
    'sourceMinorUnits',
  );
  @override
  late final GeneratedColumn<int> sourceMinorUnits = GeneratedColumn<int>(
    'source_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceCurrencyCodeMeta =
      const VerificationMeta('sourceCurrencyCode');
  @override
  late final GeneratedColumn<String> sourceCurrencyCode =
      GeneratedColumn<String>(
        'source_currency_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _destinationMinorUnitsMeta =
      const VerificationMeta('destinationMinorUnits');
  @override
  late final GeneratedColumn<int> destinationMinorUnits = GeneratedColumn<int>(
    'destination_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationCurrencyCodeMeta =
      const VerificationMeta('destinationCurrencyCode');
  @override
  late final GeneratedColumn<String> destinationCurrencyCode =
      GeneratedColumn<String>(
        'destination_currency_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMeta = const VerificationMeta(
    'deletedAtUtc',
  );
  @override
  late final GeneratedColumn<int> deletedAtUtc = GeneratedColumn<int>(
    'deleted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    sourceAccountId,
    destinationAccountId,
    sourceMinorUnits,
    sourceCurrencyCode,
    destinationMinorUnits,
    destinationCurrencyCode,
    businessDate,
    note,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
        _sourceAccountIdMeta,
        sourceAccountId.isAcceptableOrUnknown(
          data['source_account_id']!,
          _sourceAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceAccountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationAccountIdMeta);
    }
    if (data.containsKey('source_minor_units')) {
      context.handle(
        _sourceMinorUnitsMeta,
        sourceMinorUnits.isAcceptableOrUnknown(
          data['source_minor_units']!,
          _sourceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceMinorUnitsMeta);
    }
    if (data.containsKey('source_currency_code')) {
      context.handle(
        _sourceCurrencyCodeMeta,
        sourceCurrencyCode.isAcceptableOrUnknown(
          data['source_currency_code']!,
          _sourceCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceCurrencyCodeMeta);
    }
    if (data.containsKey('destination_minor_units')) {
      context.handle(
        _destinationMinorUnitsMeta,
        destinationMinorUnits.isAcceptableOrUnknown(
          data['destination_minor_units']!,
          _destinationMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMinorUnitsMeta);
    }
    if (data.containsKey('destination_currency_code')) {
      context.handle(
        _destinationCurrencyCodeMeta,
        destinationCurrencyCode.isAcceptableOrUnknown(
          data['destination_currency_code']!,
          _destinationCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationCurrencyCodeMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('deleted_at_utc')) {
      context.handle(
        _deletedAtUtcMeta,
        deletedAtUtc.isAcceptableOrUnknown(
          data['deleted_at_utc']!,
          _deletedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      sourceAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      )!,
      sourceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_minor_units'],
      )!,
      sourceCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_currency_code'],
      )!,
      destinationMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destination_minor_units'],
      )!,
      destinationCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_currency_code'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      deletedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc'],
      ),
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }
}

class Transfer extends DataClass implements Insertable<Transfer> {
  final String id;
  final String profileId;
  final String sourceAccountId;
  final String destinationAccountId;
  final int sourceMinorUnits;
  final String sourceCurrencyCode;
  final int destinationMinorUnits;
  final String destinationCurrencyCode;
  final String businessDate;
  final String? note;
  final int createdAtUtc;
  final int updatedAtUtc;
  final int? deletedAtUtc;
  const Transfer({
    required this.id,
    required this.profileId,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.sourceMinorUnits,
    required this.sourceCurrencyCode,
    required this.destinationMinorUnits,
    required this.destinationCurrencyCode,
    required this.businessDate,
    this.note,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source_account_id'] = Variable<String>(sourceAccountId);
    map['destination_account_id'] = Variable<String>(destinationAccountId);
    map['source_minor_units'] = Variable<int>(sourceMinorUnits);
    map['source_currency_code'] = Variable<String>(sourceCurrencyCode);
    map['destination_minor_units'] = Variable<int>(destinationMinorUnits);
    map['destination_currency_code'] = Variable<String>(
      destinationCurrencyCode,
    );
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    if (!nullToAbsent || deletedAtUtc != null) {
      map['deleted_at_utc'] = Variable<int>(deletedAtUtc);
    }
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      id: Value(id),
      profileId: Value(profileId),
      sourceAccountId: Value(sourceAccountId),
      destinationAccountId: Value(destinationAccountId),
      sourceMinorUnits: Value(sourceMinorUnits),
      sourceCurrencyCode: Value(sourceCurrencyCode),
      destinationMinorUnits: Value(destinationMinorUnits),
      destinationCurrencyCode: Value(destinationCurrencyCode),
      businessDate: Value(businessDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      deletedAtUtc: deletedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtc),
    );
  }

  factory Transfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transfer(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      sourceAccountId: serializer.fromJson<String>(json['sourceAccountId']),
      destinationAccountId: serializer.fromJson<String>(
        json['destinationAccountId'],
      ),
      sourceMinorUnits: serializer.fromJson<int>(json['sourceMinorUnits']),
      sourceCurrencyCode: serializer.fromJson<String>(
        json['sourceCurrencyCode'],
      ),
      destinationMinorUnits: serializer.fromJson<int>(
        json['destinationMinorUnits'],
      ),
      destinationCurrencyCode: serializer.fromJson<String>(
        json['destinationCurrencyCode'],
      ),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
      deletedAtUtc: serializer.fromJson<int?>(json['deletedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'sourceAccountId': serializer.toJson<String>(sourceAccountId),
      'destinationAccountId': serializer.toJson<String>(destinationAccountId),
      'sourceMinorUnits': serializer.toJson<int>(sourceMinorUnits),
      'sourceCurrencyCode': serializer.toJson<String>(sourceCurrencyCode),
      'destinationMinorUnits': serializer.toJson<int>(destinationMinorUnits),
      'destinationCurrencyCode': serializer.toJson<String>(
        destinationCurrencyCode,
      ),
      'businessDate': serializer.toJson<String>(businessDate),
      'note': serializer.toJson<String?>(note),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
      'deletedAtUtc': serializer.toJson<int?>(deletedAtUtc),
    };
  }

  Transfer copyWith({
    String? id,
    String? profileId,
    String? sourceAccountId,
    String? destinationAccountId,
    int? sourceMinorUnits,
    String? sourceCurrencyCode,
    int? destinationMinorUnits,
    String? destinationCurrencyCode,
    String? businessDate,
    Value<String?> note = const Value.absent(),
    int? createdAtUtc,
    int? updatedAtUtc,
    Value<int?> deletedAtUtc = const Value.absent(),
  }) => Transfer(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    sourceAccountId: sourceAccountId ?? this.sourceAccountId,
    destinationAccountId: destinationAccountId ?? this.destinationAccountId,
    sourceMinorUnits: sourceMinorUnits ?? this.sourceMinorUnits,
    sourceCurrencyCode: sourceCurrencyCode ?? this.sourceCurrencyCode,
    destinationMinorUnits: destinationMinorUnits ?? this.destinationMinorUnits,
    destinationCurrencyCode:
        destinationCurrencyCode ?? this.destinationCurrencyCode,
    businessDate: businessDate ?? this.businessDate,
    note: note.present ? note.value : this.note,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    deletedAtUtc: deletedAtUtc.present ? deletedAtUtc.value : this.deletedAtUtc,
  );
  Transfer copyWithCompanion(TransfersCompanion data) {
    return Transfer(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      sourceMinorUnits: data.sourceMinorUnits.present
          ? data.sourceMinorUnits.value
          : this.sourceMinorUnits,
      sourceCurrencyCode: data.sourceCurrencyCode.present
          ? data.sourceCurrencyCode.value
          : this.sourceCurrencyCode,
      destinationMinorUnits: data.destinationMinorUnits.present
          ? data.destinationMinorUnits.value
          : this.destinationMinorUnits,
      destinationCurrencyCode: data.destinationCurrencyCode.present
          ? data.destinationCurrencyCode.value
          : this.destinationCurrencyCode,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      deletedAtUtc: data.deletedAtUtc.present
          ? data.deletedAtUtc.value
          : this.deletedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transfer(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('sourceMinorUnits: $sourceMinorUnits, ')
          ..write('sourceCurrencyCode: $sourceCurrencyCode, ')
          ..write('destinationMinorUnits: $destinationMinorUnits, ')
          ..write('destinationCurrencyCode: $destinationCurrencyCode, ')
          ..write('businessDate: $businessDate, ')
          ..write('note: $note, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    sourceAccountId,
    destinationAccountId,
    sourceMinorUnits,
    sourceCurrencyCode,
    destinationMinorUnits,
    destinationCurrencyCode,
    businessDate,
    note,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transfer &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.sourceAccountId == this.sourceAccountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.sourceMinorUnits == this.sourceMinorUnits &&
          other.sourceCurrencyCode == this.sourceCurrencyCode &&
          other.destinationMinorUnits == this.destinationMinorUnits &&
          other.destinationCurrencyCode == this.destinationCurrencyCode &&
          other.businessDate == this.businessDate &&
          other.note == this.note &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.deletedAtUtc == this.deletedAtUtc);
}

class TransfersCompanion extends UpdateCompanion<Transfer> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> sourceAccountId;
  final Value<String> destinationAccountId;
  final Value<int> sourceMinorUnits;
  final Value<String> sourceCurrencyCode;
  final Value<int> destinationMinorUnits;
  final Value<String> destinationCurrencyCode;
  final Value<String> businessDate;
  final Value<String?> note;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int?> deletedAtUtc;
  final Value<int> rowid;
  const TransfersCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.sourceMinorUnits = const Value.absent(),
    this.sourceCurrencyCode = const Value.absent(),
    this.destinationMinorUnits = const Value.absent(),
    this.destinationCurrencyCode = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransfersCompanion.insert({
    required String id,
    required String profileId,
    required String sourceAccountId,
    required String destinationAccountId,
    required int sourceMinorUnits,
    required String sourceCurrencyCode,
    required int destinationMinorUnits,
    required String destinationCurrencyCode,
    required String businessDate,
    this.note = const Value.absent(),
    required int createdAtUtc,
    required int updatedAtUtc,
    this.deletedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       sourceAccountId = Value(sourceAccountId),
       destinationAccountId = Value(destinationAccountId),
       sourceMinorUnits = Value(sourceMinorUnits),
       sourceCurrencyCode = Value(sourceCurrencyCode),
       destinationMinorUnits = Value(destinationMinorUnits),
       destinationCurrencyCode = Value(destinationCurrencyCode),
       businessDate = Value(businessDate),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Transfer> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? sourceAccountId,
    Expression<String>? destinationAccountId,
    Expression<int>? sourceMinorUnits,
    Expression<String>? sourceCurrencyCode,
    Expression<int>? destinationMinorUnits,
    Expression<String>? destinationCurrencyCode,
    Expression<String>? businessDate,
    Expression<String>? note,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? deletedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (sourceMinorUnits != null) 'source_minor_units': sourceMinorUnits,
      if (sourceCurrencyCode != null)
        'source_currency_code': sourceCurrencyCode,
      if (destinationMinorUnits != null)
        'destination_minor_units': destinationMinorUnits,
      if (destinationCurrencyCode != null)
        'destination_currency_code': destinationCurrencyCode,
      if (businessDate != null) 'business_date': businessDate,
      if (note != null) 'note': note,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (deletedAtUtc != null) 'deleted_at_utc': deletedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? sourceAccountId,
    Value<String>? destinationAccountId,
    Value<int>? sourceMinorUnits,
    Value<String>? sourceCurrencyCode,
    Value<int>? destinationMinorUnits,
    Value<String>? destinationCurrencyCode,
    Value<String>? businessDate,
    Value<String?>? note,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int?>? deletedAtUtc,
    Value<int>? rowid,
  }) {
    return TransfersCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      sourceMinorUnits: sourceMinorUnits ?? this.sourceMinorUnits,
      sourceCurrencyCode: sourceCurrencyCode ?? this.sourceCurrencyCode,
      destinationMinorUnits:
          destinationMinorUnits ?? this.destinationMinorUnits,
      destinationCurrencyCode:
          destinationCurrencyCode ?? this.destinationCurrencyCode,
      businessDate: businessDate ?? this.businessDate,
      note: note ?? this.note,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      deletedAtUtc: deletedAtUtc ?? this.deletedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (sourceMinorUnits.present) {
      map['source_minor_units'] = Variable<int>(sourceMinorUnits.value);
    }
    if (sourceCurrencyCode.present) {
      map['source_currency_code'] = Variable<String>(sourceCurrencyCode.value);
    }
    if (destinationMinorUnits.present) {
      map['destination_minor_units'] = Variable<int>(
        destinationMinorUnits.value,
      );
    }
    if (destinationCurrencyCode.present) {
      map['destination_currency_code'] = Variable<String>(
        destinationCurrencyCode.value,
      );
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (deletedAtUtc.present) {
      map['deleted_at_utc'] = Variable<int>(deletedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('sourceMinorUnits: $sourceMinorUnits, ')
          ..write('sourceCurrencyCode: $sourceCurrencyCode, ')
          ..write('destinationMinorUnits: $destinationMinorUnits, ')
          ..write('destinationCurrencyCode: $destinationCurrencyCode, ')
          ..write('businessDate: $businessDate, ')
          ..write('note: $note, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptAttachmentsTable extends ReceiptAttachments
    with TableInfo<$ReceiptAttachmentsTable, ReceiptAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id)',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bookkeeping_transactions (id)',
    ),
  );
  static const VerificationMeta _storageKeyMeta = const VerificationMeta(
    'storageKey',
  );
  @override
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
    'storage_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256HexMeta = const VerificationMeta(
    'sha256Hex',
  );
  @override
  late final GeneratedColumn<String> sha256Hex = GeneratedColumn<String>(
    'sha256_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    transactionId,
    storageKey,
    mimeType,
    byteSize,
    sha256Hex,
    position,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('storage_key')) {
      context.handle(
        _storageKeyMeta,
        storageKey.isAcceptableOrUnknown(data['storage_key']!, _storageKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_storageKeyMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('sha256_hex')) {
      context.handle(
        _sha256HexMeta,
        sha256Hex.isAcceptableOrUnknown(data['sha256_hex']!, _sha256HexMeta),
      );
    } else if (isInserting) {
      context.missing(_sha256HexMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      storageKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_key'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      sha256Hex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256_hex'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $ReceiptAttachmentsTable createAlias(String alias) {
    return $ReceiptAttachmentsTable(attachedDatabase, alias);
  }
}

class ReceiptAttachment extends DataClass
    implements Insertable<ReceiptAttachment> {
  final String id;
  final String profileId;
  final String transactionId;
  final String storageKey;
  final String mimeType;
  final int byteSize;
  final String sha256Hex;
  final int position;
  final int createdAtUtc;
  const ReceiptAttachment({
    required this.id,
    required this.profileId,
    required this.transactionId,
    required this.storageKey,
    required this.mimeType,
    required this.byteSize,
    required this.sha256Hex,
    required this.position,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['storage_key'] = Variable<String>(storageKey);
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_size'] = Variable<int>(byteSize);
    map['sha256_hex'] = Variable<String>(sha256Hex);
    map['position'] = Variable<int>(position);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  ReceiptAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptAttachmentsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      transactionId: Value(transactionId),
      storageKey: Value(storageKey),
      mimeType: Value(mimeType),
      byteSize: Value(byteSize),
      sha256Hex: Value(sha256Hex),
      position: Value(position),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory ReceiptAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptAttachment(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      storageKey: serializer.fromJson<String>(json['storageKey']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      sha256Hex: serializer.fromJson<String>(json['sha256Hex']),
      position: serializer.fromJson<int>(json['position']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'transactionId': serializer.toJson<String>(transactionId),
      'storageKey': serializer.toJson<String>(storageKey),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'sha256Hex': serializer.toJson<String>(sha256Hex),
      'position': serializer.toJson<int>(position),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  ReceiptAttachment copyWith({
    String? id,
    String? profileId,
    String? transactionId,
    String? storageKey,
    String? mimeType,
    int? byteSize,
    String? sha256Hex,
    int? position,
    int? createdAtUtc,
  }) => ReceiptAttachment(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    transactionId: transactionId ?? this.transactionId,
    storageKey: storageKey ?? this.storageKey,
    mimeType: mimeType ?? this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    sha256Hex: sha256Hex ?? this.sha256Hex,
    position: position ?? this.position,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  ReceiptAttachment copyWithCompanion(ReceiptAttachmentsCompanion data) {
    return ReceiptAttachment(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      storageKey: data.storageKey.present
          ? data.storageKey.value
          : this.storageKey,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      sha256Hex: data.sha256Hex.present ? data.sha256Hex.value : this.sha256Hex,
      position: data.position.present ? data.position.value : this.position,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptAttachment(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('transactionId: $transactionId, ')
          ..write('storageKey: $storageKey, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('position: $position, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    transactionId,
    storageKey,
    mimeType,
    byteSize,
    sha256Hex,
    position,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptAttachment &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.transactionId == this.transactionId &&
          other.storageKey == this.storageKey &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.sha256Hex == this.sha256Hex &&
          other.position == this.position &&
          other.createdAtUtc == this.createdAtUtc);
}

class ReceiptAttachmentsCompanion extends UpdateCompanion<ReceiptAttachment> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> transactionId;
  final Value<String> storageKey;
  final Value<String> mimeType;
  final Value<int> byteSize;
  final Value<String> sha256Hex;
  final Value<int> position;
  final Value<int> createdAtUtc;
  final Value<int> rowid;
  const ReceiptAttachmentsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptAttachmentsCompanion.insert({
    required String id,
    required String profileId,
    required String transactionId,
    required String storageKey,
    required String mimeType,
    required int byteSize,
    required String sha256Hex,
    required int position,
    required int createdAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       transactionId = Value(transactionId),
       storageKey = Value(storageKey),
       mimeType = Value(mimeType),
       byteSize = Value(byteSize),
       sha256Hex = Value(sha256Hex),
       position = Value(position),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<ReceiptAttachment> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? transactionId,
    Expression<String>? storageKey,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<String>? sha256Hex,
    Expression<int>? position,
    Expression<int>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (storageKey != null) 'storage_key': storageKey,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (sha256Hex != null) 'sha256_hex': sha256Hex,
      if (position != null) 'position': position,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? transactionId,
    Value<String>? storageKey,
    Value<String>? mimeType,
    Value<int>? byteSize,
    Value<String>? sha256Hex,
    Value<int>? position,
    Value<int>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return ReceiptAttachmentsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      transactionId: transactionId ?? this.transactionId,
      storageKey: storageKey ?? this.storageKey,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      sha256Hex: sha256Hex ?? this.sha256Hex,
      position: position ?? this.position,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (sha256Hex.present) {
      map['sha256_hex'] = Variable<String>(sha256Hex.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('transactionId: $transactionId, ')
          ..write('storageKey: $storageKey, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('position: $position, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLinkStatesTable extends SyncLinkStates
    with TableInfo<$SyncLinkStatesTable, SyncLinkState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLinkStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudAccountIdMeta = const VerificationMeta(
    'cloudAccountId',
  );
  @override
  late final GeneratedColumn<String> cloudAccountId = GeneratedColumn<String>(
    'cloud_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unlinked'),
  );
  static const VerificationMeta _syncEnabledMeta = const VerificationMeta(
    'syncEnabled',
  );
  @override
  late final GeneratedColumn<bool> syncEnabled = GeneratedColumn<bool>(
    'sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsReconciliationMeta =
      const VerificationMeta('needsReconciliation');
  @override
  late final GeneratedColumn<bool> needsReconciliation = GeneratedColumn<bool>(
    'needs_reconciliation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_reconciliation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slot,
    cloudAccountId,
    state,
    syncEnabled,
    needsReconciliation,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_link_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLinkState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('cloud_account_id')) {
      context.handle(
        _cloudAccountIdMeta,
        cloudAccountId.isAcceptableOrUnknown(
          data['cloud_account_id']!,
          _cloudAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('sync_enabled')) {
      context.handle(
        _syncEnabledMeta,
        syncEnabled.isAcceptableOrUnknown(
          data['sync_enabled']!,
          _syncEnabledMeta,
        ),
      );
    }
    if (data.containsKey('needs_reconciliation')) {
      context.handle(
        _needsReconciliationMeta,
        needsReconciliation.isAcceptableOrUnknown(
          data['needs_reconciliation']!,
          _needsReconciliationMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  SyncLinkState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLinkState(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      cloudAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_account_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      syncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_enabled'],
      )!,
      needsReconciliation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_reconciliation'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $SyncLinkStatesTable createAlias(String alias) {
    return $SyncLinkStatesTable(attachedDatabase, alias);
  }
}

class SyncLinkState extends DataClass implements Insertable<SyncLinkState> {
  final int slot;
  final String? cloudAccountId;
  final String state;
  final bool syncEnabled;
  final bool needsReconciliation;
  final int updatedAtUtc;
  const SyncLinkState({
    required this.slot,
    this.cloudAccountId,
    required this.state,
    required this.syncEnabled,
    required this.needsReconciliation,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    if (!nullToAbsent || cloudAccountId != null) {
      map['cloud_account_id'] = Variable<String>(cloudAccountId);
    }
    map['state'] = Variable<String>(state);
    map['sync_enabled'] = Variable<bool>(syncEnabled);
    map['needs_reconciliation'] = Variable<bool>(needsReconciliation);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  SyncLinkStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncLinkStatesCompanion(
      slot: Value(slot),
      cloudAccountId: cloudAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudAccountId),
      state: Value(state),
      syncEnabled: Value(syncEnabled),
      needsReconciliation: Value(needsReconciliation),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory SyncLinkState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLinkState(
      slot: serializer.fromJson<int>(json['slot']),
      cloudAccountId: serializer.fromJson<String?>(json['cloudAccountId']),
      state: serializer.fromJson<String>(json['state']),
      syncEnabled: serializer.fromJson<bool>(json['syncEnabled']),
      needsReconciliation: serializer.fromJson<bool>(
        json['needsReconciliation'],
      ),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'cloudAccountId': serializer.toJson<String?>(cloudAccountId),
      'state': serializer.toJson<String>(state),
      'syncEnabled': serializer.toJson<bool>(syncEnabled),
      'needsReconciliation': serializer.toJson<bool>(needsReconciliation),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  SyncLinkState copyWith({
    int? slot,
    Value<String?> cloudAccountId = const Value.absent(),
    String? state,
    bool? syncEnabled,
    bool? needsReconciliation,
    int? updatedAtUtc,
  }) => SyncLinkState(
    slot: slot ?? this.slot,
    cloudAccountId: cloudAccountId.present
        ? cloudAccountId.value
        : this.cloudAccountId,
    state: state ?? this.state,
    syncEnabled: syncEnabled ?? this.syncEnabled,
    needsReconciliation: needsReconciliation ?? this.needsReconciliation,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  SyncLinkState copyWithCompanion(SyncLinkStatesCompanion data) {
    return SyncLinkState(
      slot: data.slot.present ? data.slot.value : this.slot,
      cloudAccountId: data.cloudAccountId.present
          ? data.cloudAccountId.value
          : this.cloudAccountId,
      state: data.state.present ? data.state.value : this.state,
      syncEnabled: data.syncEnabled.present
          ? data.syncEnabled.value
          : this.syncEnabled,
      needsReconciliation: data.needsReconciliation.present
          ? data.needsReconciliation.value
          : this.needsReconciliation,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLinkState(')
          ..write('slot: $slot, ')
          ..write('cloudAccountId: $cloudAccountId, ')
          ..write('state: $state, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('needsReconciliation: $needsReconciliation, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slot,
    cloudAccountId,
    state,
    syncEnabled,
    needsReconciliation,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLinkState &&
          other.slot == this.slot &&
          other.cloudAccountId == this.cloudAccountId &&
          other.state == this.state &&
          other.syncEnabled == this.syncEnabled &&
          other.needsReconciliation == this.needsReconciliation &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class SyncLinkStatesCompanion extends UpdateCompanion<SyncLinkState> {
  final Value<int> slot;
  final Value<String?> cloudAccountId;
  final Value<String> state;
  final Value<bool> syncEnabled;
  final Value<bool> needsReconciliation;
  final Value<int> updatedAtUtc;
  const SyncLinkStatesCompanion({
    this.slot = const Value.absent(),
    this.cloudAccountId = const Value.absent(),
    this.state = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.needsReconciliation = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  SyncLinkStatesCompanion.insert({
    this.slot = const Value.absent(),
    this.cloudAccountId = const Value.absent(),
    this.state = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.needsReconciliation = const Value.absent(),
    required int updatedAtUtc,
  }) : updatedAtUtc = Value(updatedAtUtc);
  static Insertable<SyncLinkState> custom({
    Expression<int>? slot,
    Expression<String>? cloudAccountId,
    Expression<String>? state,
    Expression<bool>? syncEnabled,
    Expression<bool>? needsReconciliation,
    Expression<int>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (cloudAccountId != null) 'cloud_account_id': cloudAccountId,
      if (state != null) 'state': state,
      if (syncEnabled != null) 'sync_enabled': syncEnabled,
      if (needsReconciliation != null)
        'needs_reconciliation': needsReconciliation,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  SyncLinkStatesCompanion copyWith({
    Value<int>? slot,
    Value<String?>? cloudAccountId,
    Value<String>? state,
    Value<bool>? syncEnabled,
    Value<bool>? needsReconciliation,
    Value<int>? updatedAtUtc,
  }) {
    return SyncLinkStatesCompanion(
      slot: slot ?? this.slot,
      cloudAccountId: cloudAccountId ?? this.cloudAccountId,
      state: state ?? this.state,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      needsReconciliation: needsReconciliation ?? this.needsReconciliation,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (cloudAccountId.present) {
      map['cloud_account_id'] = Variable<String>(cloudAccountId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (syncEnabled.present) {
      map['sync_enabled'] = Variable<bool>(syncEnabled.value);
    }
    if (needsReconciliation.present) {
      map['needs_reconciliation'] = Variable<bool>(needsReconciliation.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLinkStatesCompanion(')
          ..write('slot: $slot, ')
          ..write('cloudAccountId: $cloudAccountId, ')
          ..write('state: $state, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('needsReconciliation: $needsReconciliation, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SyncDeviceStatesTable extends SyncDeviceStates
    with TableInfo<$SyncDeviceStatesTable, SyncDeviceState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDeviceStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [slot, deviceId, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_device_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDeviceState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  SyncDeviceState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDeviceState(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $SyncDeviceStatesTable createAlias(String alias) {
    return $SyncDeviceStatesTable(attachedDatabase, alias);
  }
}

class SyncDeviceState extends DataClass implements Insertable<SyncDeviceState> {
  final int slot;
  final String deviceId;
  final int createdAtUtc;
  const SyncDeviceState({
    required this.slot,
    required this.deviceId,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  SyncDeviceStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncDeviceStatesCompanion(
      slot: Value(slot),
      deviceId: Value(deviceId),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory SyncDeviceState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDeviceState(
      slot: serializer.fromJson<int>(json['slot']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  SyncDeviceState copyWith({int? slot, String? deviceId, int? createdAtUtc}) =>
      SyncDeviceState(
        slot: slot ?? this.slot,
        deviceId: deviceId ?? this.deviceId,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      );
  SyncDeviceState copyWithCompanion(SyncDeviceStatesCompanion data) {
    return SyncDeviceState(
      slot: data.slot.present ? data.slot.value : this.slot,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeviceState(')
          ..write('slot: $slot, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, deviceId, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDeviceState &&
          other.slot == this.slot &&
          other.deviceId == this.deviceId &&
          other.createdAtUtc == this.createdAtUtc);
}

class SyncDeviceStatesCompanion extends UpdateCompanion<SyncDeviceState> {
  final Value<int> slot;
  final Value<String> deviceId;
  final Value<int> createdAtUtc;
  const SyncDeviceStatesCompanion({
    this.slot = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  SyncDeviceStatesCompanion.insert({
    this.slot = const Value.absent(),
    required String deviceId,
    required int createdAtUtc,
  }) : deviceId = Value(deviceId),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<SyncDeviceState> custom({
    Expression<int>? slot,
    Expression<String>? deviceId,
    Expression<int>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  SyncDeviceStatesCompanion copyWith({
    Value<int>? slot,
    Value<String>? deviceId,
    Value<int>? createdAtUtc,
  }) {
    return SyncDeviceStatesCompanion(
      slot: slot ?? this.slot,
      deviceId: deviceId ?? this.deviceId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeviceStatesCompanion(')
          ..write('slot: $slot, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAppliedSequenceMeta =
      const VerificationMeta('lastAppliedSequence');
  @override
  late final GeneratedColumn<int> lastAppliedSequence = GeneratedColumn<int>(
    'last_applied_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [slot, lastAppliedSequence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('last_applied_sequence')) {
      context.handle(
        _lastAppliedSequenceMeta,
        lastAppliedSequence.isAcceptableOrUnknown(
          data['last_applied_sequence']!,
          _lastAppliedSequenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      lastAppliedSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_applied_sequence'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final int slot;
  final int lastAppliedSequence;
  const SyncCursor({required this.slot, required this.lastAppliedSequence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    map['last_applied_sequence'] = Variable<int>(lastAppliedSequence);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      slot: Value(slot),
      lastAppliedSequence: Value(lastAppliedSequence),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      slot: serializer.fromJson<int>(json['slot']),
      lastAppliedSequence: serializer.fromJson<int>(
        json['lastAppliedSequence'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'lastAppliedSequence': serializer.toJson<int>(lastAppliedSequence),
    };
  }

  SyncCursor copyWith({int? slot, int? lastAppliedSequence}) => SyncCursor(
    slot: slot ?? this.slot,
    lastAppliedSequence: lastAppliedSequence ?? this.lastAppliedSequence,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      slot: data.slot.present ? data.slot.value : this.slot,
      lastAppliedSequence: data.lastAppliedSequence.present
          ? data.lastAppliedSequence.value
          : this.lastAppliedSequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('slot: $slot, ')
          ..write('lastAppliedSequence: $lastAppliedSequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, lastAppliedSequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.slot == this.slot &&
          other.lastAppliedSequence == this.lastAppliedSequence);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<int> slot;
  final Value<int> lastAppliedSequence;
  const SyncCursorsCompanion({
    this.slot = const Value.absent(),
    this.lastAppliedSequence = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    this.slot = const Value.absent(),
    this.lastAppliedSequence = const Value.absent(),
  });
  static Insertable<SyncCursor> custom({
    Expression<int>? slot,
    Expression<int>? lastAppliedSequence,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (lastAppliedSequence != null)
        'last_applied_sequence': lastAppliedSequence,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<int>? slot,
    Value<int>? lastAppliedSequence,
  }) {
    return SyncCursorsCompanion(
      slot: slot ?? this.slot,
      lastAppliedSequence: lastAppliedSequence ?? this.lastAppliedSequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (lastAppliedSequence.present) {
      map['last_applied_sequence'] = Variable<int>(lastAppliedSequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('slot: $slot, ')
          ..write('lastAppliedSequence: $lastAppliedSequence')
          ..write(')'))
        .toString();
  }
}

class $SyncEntityStatesTable extends SyncEntityStates
    with TableInfo<$SyncEntityStatesTable, SyncEntityState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntityStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    serverVersion,
    serverRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entity_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEntityState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverVersionMeta);
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverRevisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncEntityState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntityState(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      )!,
    );
  }

  @override
  $SyncEntityStatesTable createAlias(String alias) {
    return $SyncEntityStatesTable(attachedDatabase, alias);
  }
}

class SyncEntityState extends DataClass implements Insertable<SyncEntityState> {
  final String entityType;
  final String entityId;
  final int serverVersion;
  final int serverRevision;
  const SyncEntityState({
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    required this.serverRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['server_version'] = Variable<int>(serverVersion);
    map['server_revision'] = Variable<int>(serverRevision);
    return map;
  }

  SyncEntityStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncEntityStatesCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      serverVersion: Value(serverVersion),
      serverRevision: Value(serverRevision),
    );
  }

  factory SyncEntityState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntityState(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'serverRevision': serializer.toJson<int>(serverRevision),
    };
  }

  SyncEntityState copyWith({
    String? entityType,
    String? entityId,
    int? serverVersion,
    int? serverRevision,
  }) => SyncEntityState(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    serverVersion: serverVersion ?? this.serverVersion,
    serverRevision: serverRevision ?? this.serverRevision,
  );
  SyncEntityState copyWithCompanion(SyncEntityStatesCompanion data) {
    return SyncEntityState(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityState(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('serverRevision: $serverRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityType, entityId, serverVersion, serverRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntityState &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.serverVersion == this.serverVersion &&
          other.serverRevision == this.serverRevision);
}

class SyncEntityStatesCompanion extends UpdateCompanion<SyncEntityState> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> serverVersion;
  final Value<int> serverRevision;
  final Value<int> rowid;
  const SyncEntityStatesCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntityStatesCompanion.insert({
    required String entityType,
    required String entityId,
    required int serverVersion,
    required int serverRevision,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       serverVersion = Value(serverVersion),
       serverRevision = Value(serverRevision);
  static Insertable<SyncEntityState> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? serverVersion,
    Expression<int>? serverRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (serverVersion != null) 'server_version': serverVersion,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntityStatesCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? serverVersion,
    Value<int>? serverRevision,
    Value<int>? rowid,
  }) {
    return SyncEntityStatesCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      serverVersion: serverVersion ?? this.serverVersion,
      serverRevision: serverRevision ?? this.serverRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityStatesCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queueSequenceMeta = const VerificationMeta(
    'queueSequence',
  );
  @override
  late final GeneratedColumn<int> queueSequence = GeneratedColumn<int>(
    'queue_sequence',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseServerVersionMeta = const VerificationMeta(
    'baseServerVersion',
  );
  @override
  late final GeneratedColumn<int> baseServerVersion = GeneratedColumn<int>(
    'base_server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtUtcMeta = const VerificationMeta(
    'lastAttemptAtUtc',
  );
  @override
  late final GeneratedColumn<int> lastAttemptAtUtc = GeneratedColumn<int>(
    'last_attempt_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtUtcMeta = const VerificationMeta(
    'nextAttemptAtUtc',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAtUtc = GeneratedColumn<int>(
    'next_attempt_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFailureCodeMeta = const VerificationMeta(
    'lastFailureCode',
  );
  @override
  late final GeneratedColumn<String> lastFailureCode = GeneratedColumn<String>(
    'last_failure_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    queueSequence,
    mutationId,
    entityType,
    entityId,
    operation,
    baseServerVersion,
    payloadJson,
    state,
    attemptCount,
    lastAttemptAtUtc,
    nextAttemptAtUtc,
    lastFailureCode,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('queue_sequence')) {
      context.handle(
        _queueSequenceMeta,
        queueSequence.isAcceptableOrUnknown(
          data['queue_sequence']!,
          _queueSequenceMeta,
        ),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('base_server_version')) {
      context.handle(
        _baseServerVersionMeta,
        baseServerVersion.isAcceptableOrUnknown(
          data['base_server_version']!,
          _baseServerVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at_utc')) {
      context.handle(
        _lastAttemptAtUtcMeta,
        lastAttemptAtUtc.isAcceptableOrUnknown(
          data['last_attempt_at_utc']!,
          _lastAttemptAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at_utc')) {
      context.handle(
        _nextAttemptAtUtcMeta,
        nextAttemptAtUtc.isAcceptableOrUnknown(
          data['next_attempt_at_utc']!,
          _nextAttemptAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_failure_code')) {
      context.handle(
        _lastFailureCodeMeta,
        lastFailureCode.isAcceptableOrUnknown(
          data['last_failure_code']!,
          _lastFailureCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queueSequence};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      queueSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_sequence'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      baseServerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_server_version'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastAttemptAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_attempt_at_utc'],
      ),
      nextAttemptAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at_utc'],
      ),
      lastFailureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_failure_code'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int queueSequence;
  final String mutationId;
  final String entityType;
  final String entityId;
  final String operation;
  final int? baseServerVersion;
  final String payloadJson;
  final String state;
  final int attemptCount;
  final int? lastAttemptAtUtc;
  final int? nextAttemptAtUtc;
  final String? lastFailureCode;
  final int createdAtUtc;
  const SyncOutboxData({
    required this.queueSequence,
    required this.mutationId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.baseServerVersion,
    required this.payloadJson,
    required this.state,
    required this.attemptCount,
    this.lastAttemptAtUtc,
    this.nextAttemptAtUtc,
    this.lastFailureCode,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['queue_sequence'] = Variable<int>(queueSequence);
    map['mutation_id'] = Variable<String>(mutationId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || baseServerVersion != null) {
      map['base_server_version'] = Variable<int>(baseServerVersion);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['state'] = Variable<String>(state);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastAttemptAtUtc != null) {
      map['last_attempt_at_utc'] = Variable<int>(lastAttemptAtUtc);
    }
    if (!nullToAbsent || nextAttemptAtUtc != null) {
      map['next_attempt_at_utc'] = Variable<int>(nextAttemptAtUtc);
    }
    if (!nullToAbsent || lastFailureCode != null) {
      map['last_failure_code'] = Variable<String>(lastFailureCode);
    }
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      queueSequence: Value(queueSequence),
      mutationId: Value(mutationId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      baseServerVersion: baseServerVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseServerVersion),
      payloadJson: Value(payloadJson),
      state: Value(state),
      attemptCount: Value(attemptCount),
      lastAttemptAtUtc: lastAttemptAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAtUtc),
      nextAttemptAtUtc: nextAttemptAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAtUtc),
      lastFailureCode: lastFailureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFailureCode),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      queueSequence: serializer.fromJson<int>(json['queueSequence']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      baseServerVersion: serializer.fromJson<int?>(json['baseServerVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      state: serializer.fromJson<String>(json['state']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastAttemptAtUtc: serializer.fromJson<int?>(json['lastAttemptAtUtc']),
      nextAttemptAtUtc: serializer.fromJson<int?>(json['nextAttemptAtUtc']),
      lastFailureCode: serializer.fromJson<String?>(json['lastFailureCode']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queueSequence': serializer.toJson<int>(queueSequence),
      'mutationId': serializer.toJson<String>(mutationId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'baseServerVersion': serializer.toJson<int?>(baseServerVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'state': serializer.toJson<String>(state),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastAttemptAtUtc': serializer.toJson<int?>(lastAttemptAtUtc),
      'nextAttemptAtUtc': serializer.toJson<int?>(nextAttemptAtUtc),
      'lastFailureCode': serializer.toJson<String?>(lastFailureCode),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  SyncOutboxData copyWith({
    int? queueSequence,
    String? mutationId,
    String? entityType,
    String? entityId,
    String? operation,
    Value<int?> baseServerVersion = const Value.absent(),
    String? payloadJson,
    String? state,
    int? attemptCount,
    Value<int?> lastAttemptAtUtc = const Value.absent(),
    Value<int?> nextAttemptAtUtc = const Value.absent(),
    Value<String?> lastFailureCode = const Value.absent(),
    int? createdAtUtc,
  }) => SyncOutboxData(
    queueSequence: queueSequence ?? this.queueSequence,
    mutationId: mutationId ?? this.mutationId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    baseServerVersion: baseServerVersion.present
        ? baseServerVersion.value
        : this.baseServerVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    lastAttemptAtUtc: lastAttemptAtUtc.present
        ? lastAttemptAtUtc.value
        : this.lastAttemptAtUtc,
    nextAttemptAtUtc: nextAttemptAtUtc.present
        ? nextAttemptAtUtc.value
        : this.nextAttemptAtUtc,
    lastFailureCode: lastFailureCode.present
        ? lastFailureCode.value
        : this.lastFailureCode,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      queueSequence: data.queueSequence.present
          ? data.queueSequence.value
          : this.queueSequence,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      baseServerVersion: data.baseServerVersion.present
          ? data.baseServerVersion.value
          : this.baseServerVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      state: data.state.present ? data.state.value : this.state,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastAttemptAtUtc: data.lastAttemptAtUtc.present
          ? data.lastAttemptAtUtc.value
          : this.lastAttemptAtUtc,
      nextAttemptAtUtc: data.nextAttemptAtUtc.present
          ? data.nextAttemptAtUtc.value
          : this.nextAttemptAtUtc,
      lastFailureCode: data.lastFailureCode.present
          ? data.lastFailureCode.value
          : this.lastFailureCode,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('queueSequence: $queueSequence, ')
          ..write('mutationId: $mutationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('baseServerVersion: $baseServerVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAtUtc: $lastAttemptAtUtc, ')
          ..write('nextAttemptAtUtc: $nextAttemptAtUtc, ')
          ..write('lastFailureCode: $lastFailureCode, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    queueSequence,
    mutationId,
    entityType,
    entityId,
    operation,
    baseServerVersion,
    payloadJson,
    state,
    attemptCount,
    lastAttemptAtUtc,
    nextAttemptAtUtc,
    lastFailureCode,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.queueSequence == this.queueSequence &&
          other.mutationId == this.mutationId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.baseServerVersion == this.baseServerVersion &&
          other.payloadJson == this.payloadJson &&
          other.state == this.state &&
          other.attemptCount == this.attemptCount &&
          other.lastAttemptAtUtc == this.lastAttemptAtUtc &&
          other.nextAttemptAtUtc == this.nextAttemptAtUtc &&
          other.lastFailureCode == this.lastFailureCode &&
          other.createdAtUtc == this.createdAtUtc);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> queueSequence;
  final Value<String> mutationId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<int?> baseServerVersion;
  final Value<String> payloadJson;
  final Value<String> state;
  final Value<int> attemptCount;
  final Value<int?> lastAttemptAtUtc;
  final Value<int?> nextAttemptAtUtc;
  final Value<String?> lastFailureCode;
  final Value<int> createdAtUtc;
  const SyncOutboxCompanion({
    this.queueSequence = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.baseServerVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAtUtc = const Value.absent(),
    this.nextAttemptAtUtc = const Value.absent(),
    this.lastFailureCode = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.queueSequence = const Value.absent(),
    required String mutationId,
    required String entityType,
    required String entityId,
    required String operation,
    this.baseServerVersion = const Value.absent(),
    required String payloadJson,
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAtUtc = const Value.absent(),
    this.nextAttemptAtUtc = const Value.absent(),
    this.lastFailureCode = const Value.absent(),
    required int createdAtUtc,
  }) : mutationId = Value(mutationId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? queueSequence,
    Expression<String>? mutationId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<int>? baseServerVersion,
    Expression<String>? payloadJson,
    Expression<String>? state,
    Expression<int>? attemptCount,
    Expression<int>? lastAttemptAtUtc,
    Expression<int>? nextAttemptAtUtc,
    Expression<String>? lastFailureCode,
    Expression<int>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (queueSequence != null) 'queue_sequence': queueSequence,
      if (mutationId != null) 'mutation_id': mutationId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (baseServerVersion != null) 'base_server_version': baseServerVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (state != null) 'state': state,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastAttemptAtUtc != null) 'last_attempt_at_utc': lastAttemptAtUtc,
      if (nextAttemptAtUtc != null) 'next_attempt_at_utc': nextAttemptAtUtc,
      if (lastFailureCode != null) 'last_failure_code': lastFailureCode,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? queueSequence,
    Value<String>? mutationId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<int?>? baseServerVersion,
    Value<String>? payloadJson,
    Value<String>? state,
    Value<int>? attemptCount,
    Value<int?>? lastAttemptAtUtc,
    Value<int?>? nextAttemptAtUtc,
    Value<String?>? lastFailureCode,
    Value<int>? createdAtUtc,
  }) {
    return SyncOutboxCompanion(
      queueSequence: queueSequence ?? this.queueSequence,
      mutationId: mutationId ?? this.mutationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      baseServerVersion: baseServerVersion ?? this.baseServerVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAtUtc: lastAttemptAtUtc ?? this.lastAttemptAtUtc,
      nextAttemptAtUtc: nextAttemptAtUtc ?? this.nextAttemptAtUtc,
      lastFailureCode: lastFailureCode ?? this.lastFailureCode,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queueSequence.present) {
      map['queue_sequence'] = Variable<int>(queueSequence.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (baseServerVersion.present) {
      map['base_server_version'] = Variable<int>(baseServerVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastAttemptAtUtc.present) {
      map['last_attempt_at_utc'] = Variable<int>(lastAttemptAtUtc.value);
    }
    if (nextAttemptAtUtc.present) {
      map['next_attempt_at_utc'] = Variable<int>(nextAttemptAtUtc.value);
    }
    if (lastFailureCode.present) {
      map['last_failure_code'] = Variable<String>(lastFailureCode.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('queueSequence: $queueSequence, ')
          ..write('mutationId: $mutationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('baseServerVersion: $baseServerVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAtUtc: $lastAttemptAtUtc, ')
          ..write('nextAttemptAtUtc: $nextAttemptAtUtc, ')
          ..write('lastFailureCode: $lastFailureCode, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseServerVersionMeta = const VerificationMeta(
    'baseServerVersion',
  );
  @override
  late final GeneratedColumn<int> baseServerVersion = GeneratedColumn<int>(
    'base_server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteServerVersionMeta =
      const VerificationMeta('remoteServerVersion');
  @override
  late final GeneratedColumn<int> remoteServerVersion = GeneratedColumn<int>(
    'remote_server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteServerRevisionMeta =
      const VerificationMeta('remoteServerRevision');
  @override
  late final GeneratedColumn<int> remoteServerRevision = GeneratedColumn<int>(
    'remote_server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localCandidateJsonMeta =
      const VerificationMeta('localCandidateJson');
  @override
  late final GeneratedColumn<String> localCandidateJson =
      GeneratedColumn<String>(
        'local_candidate_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _remoteCandidateJsonMeta =
      const VerificationMeta('remoteCandidateJson');
  @override
  late final GeneratedColumn<String> remoteCandidateJson =
      GeneratedColumn<String>(
        'remote_candidate_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _detectedAtUtcMeta = const VerificationMeta(
    'detectedAtUtc',
  );
  @override
  late final GeneratedColumn<int> detectedAtUtc = GeneratedColumn<int>(
    'detected_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unresolved'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    mutationId,
    baseServerVersion,
    remoteServerVersion,
    remoteServerRevision,
    localCandidateJson,
    remoteCandidateJson,
    detectedAtUtc,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    }
    if (data.containsKey('base_server_version')) {
      context.handle(
        _baseServerVersionMeta,
        baseServerVersion.isAcceptableOrUnknown(
          data['base_server_version']!,
          _baseServerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseServerVersionMeta);
    }
    if (data.containsKey('remote_server_version')) {
      context.handle(
        _remoteServerVersionMeta,
        remoteServerVersion.isAcceptableOrUnknown(
          data['remote_server_version']!,
          _remoteServerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteServerVersionMeta);
    }
    if (data.containsKey('remote_server_revision')) {
      context.handle(
        _remoteServerRevisionMeta,
        remoteServerRevision.isAcceptableOrUnknown(
          data['remote_server_revision']!,
          _remoteServerRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteServerRevisionMeta);
    }
    if (data.containsKey('local_candidate_json')) {
      context.handle(
        _localCandidateJsonMeta,
        localCandidateJson.isAcceptableOrUnknown(
          data['local_candidate_json']!,
          _localCandidateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCandidateJsonMeta);
    }
    if (data.containsKey('remote_candidate_json')) {
      context.handle(
        _remoteCandidateJsonMeta,
        remoteCandidateJson.isAcceptableOrUnknown(
          data['remote_candidate_json']!,
          _remoteCandidateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteCandidateJsonMeta);
    }
    if (data.containsKey('detected_at_utc')) {
      context.handle(
        _detectedAtUtcMeta,
        detectedAtUtc.isAcceptableOrUnknown(
          data['detected_at_utc']!,
          _detectedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedAtUtcMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      ),
      baseServerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_server_version'],
      )!,
      remoteServerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_server_version'],
      )!,
      remoteServerRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_server_revision'],
      )!,
      localCandidateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_candidate_json'],
      )!,
      remoteCandidateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_candidate_json'],
      )!,
      detectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_at_utc'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String entityType;
  final String entityId;
  final String? mutationId;
  final int baseServerVersion;
  final int remoteServerVersion;
  final int remoteServerRevision;
  final String localCandidateJson;
  final String remoteCandidateJson;
  final int detectedAtUtc;
  final String status;
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.mutationId,
    required this.baseServerVersion,
    required this.remoteServerVersion,
    required this.remoteServerRevision,
    required this.localCandidateJson,
    required this.remoteCandidateJson,
    required this.detectedAtUtc,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || mutationId != null) {
      map['mutation_id'] = Variable<String>(mutationId);
    }
    map['base_server_version'] = Variable<int>(baseServerVersion);
    map['remote_server_version'] = Variable<int>(remoteServerVersion);
    map['remote_server_revision'] = Variable<int>(remoteServerRevision);
    map['local_candidate_json'] = Variable<String>(localCandidateJson);
    map['remote_candidate_json'] = Variable<String>(remoteCandidateJson);
    map['detected_at_utc'] = Variable<int>(detectedAtUtc);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      mutationId: mutationId == null && nullToAbsent
          ? const Value.absent()
          : Value(mutationId),
      baseServerVersion: Value(baseServerVersion),
      remoteServerVersion: Value(remoteServerVersion),
      remoteServerRevision: Value(remoteServerRevision),
      localCandidateJson: Value(localCandidateJson),
      remoteCandidateJson: Value(remoteCandidateJson),
      detectedAtUtc: Value(detectedAtUtc),
      status: Value(status),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      mutationId: serializer.fromJson<String?>(json['mutationId']),
      baseServerVersion: serializer.fromJson<int>(json['baseServerVersion']),
      remoteServerVersion: serializer.fromJson<int>(
        json['remoteServerVersion'],
      ),
      remoteServerRevision: serializer.fromJson<int>(
        json['remoteServerRevision'],
      ),
      localCandidateJson: serializer.fromJson<String>(
        json['localCandidateJson'],
      ),
      remoteCandidateJson: serializer.fromJson<String>(
        json['remoteCandidateJson'],
      ),
      detectedAtUtc: serializer.fromJson<int>(json['detectedAtUtc']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'mutationId': serializer.toJson<String?>(mutationId),
      'baseServerVersion': serializer.toJson<int>(baseServerVersion),
      'remoteServerVersion': serializer.toJson<int>(remoteServerVersion),
      'remoteServerRevision': serializer.toJson<int>(remoteServerRevision),
      'localCandidateJson': serializer.toJson<String>(localCandidateJson),
      'remoteCandidateJson': serializer.toJson<String>(remoteCandidateJson),
      'detectedAtUtc': serializer.toJson<int>(detectedAtUtc),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? entityType,
    String? entityId,
    Value<String?> mutationId = const Value.absent(),
    int? baseServerVersion,
    int? remoteServerVersion,
    int? remoteServerRevision,
    String? localCandidateJson,
    String? remoteCandidateJson,
    int? detectedAtUtc,
    String? status,
  }) => SyncConflict(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    mutationId: mutationId.present ? mutationId.value : this.mutationId,
    baseServerVersion: baseServerVersion ?? this.baseServerVersion,
    remoteServerVersion: remoteServerVersion ?? this.remoteServerVersion,
    remoteServerRevision: remoteServerRevision ?? this.remoteServerRevision,
    localCandidateJson: localCandidateJson ?? this.localCandidateJson,
    remoteCandidateJson: remoteCandidateJson ?? this.remoteCandidateJson,
    detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
    status: status ?? this.status,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      baseServerVersion: data.baseServerVersion.present
          ? data.baseServerVersion.value
          : this.baseServerVersion,
      remoteServerVersion: data.remoteServerVersion.present
          ? data.remoteServerVersion.value
          : this.remoteServerVersion,
      remoteServerRevision: data.remoteServerRevision.present
          ? data.remoteServerRevision.value
          : this.remoteServerRevision,
      localCandidateJson: data.localCandidateJson.present
          ? data.localCandidateJson.value
          : this.localCandidateJson,
      remoteCandidateJson: data.remoteCandidateJson.present
          ? data.remoteCandidateJson.value
          : this.remoteCandidateJson,
      detectedAtUtc: data.detectedAtUtc.present
          ? data.detectedAtUtc.value
          : this.detectedAtUtc,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('mutationId: $mutationId, ')
          ..write('baseServerVersion: $baseServerVersion, ')
          ..write('remoteServerVersion: $remoteServerVersion, ')
          ..write('remoteServerRevision: $remoteServerRevision, ')
          ..write('localCandidateJson: $localCandidateJson, ')
          ..write('remoteCandidateJson: $remoteCandidateJson, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    mutationId,
    baseServerVersion,
    remoteServerVersion,
    remoteServerRevision,
    localCandidateJson,
    remoteCandidateJson,
    detectedAtUtc,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.mutationId == this.mutationId &&
          other.baseServerVersion == this.baseServerVersion &&
          other.remoteServerVersion == this.remoteServerVersion &&
          other.remoteServerRevision == this.remoteServerRevision &&
          other.localCandidateJson == this.localCandidateJson &&
          other.remoteCandidateJson == this.remoteCandidateJson &&
          other.detectedAtUtc == this.detectedAtUtc &&
          other.status == this.status);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> mutationId;
  final Value<int> baseServerVersion;
  final Value<int> remoteServerVersion;
  final Value<int> remoteServerRevision;
  final Value<String> localCandidateJson;
  final Value<String> remoteCandidateJson;
  final Value<int> detectedAtUtc;
  final Value<String> status;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.baseServerVersion = const Value.absent(),
    this.remoteServerVersion = const Value.absent(),
    this.remoteServerRevision = const Value.absent(),
    this.localCandidateJson = const Value.absent(),
    this.remoteCandidateJson = const Value.absent(),
    this.detectedAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    this.mutationId = const Value.absent(),
    required int baseServerVersion,
    required int remoteServerVersion,
    required int remoteServerRevision,
    required String localCandidateJson,
    required String remoteCandidateJson,
    required int detectedAtUtc,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       baseServerVersion = Value(baseServerVersion),
       remoteServerVersion = Value(remoteServerVersion),
       remoteServerRevision = Value(remoteServerRevision),
       localCandidateJson = Value(localCandidateJson),
       remoteCandidateJson = Value(remoteCandidateJson),
       detectedAtUtc = Value(detectedAtUtc);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? mutationId,
    Expression<int>? baseServerVersion,
    Expression<int>? remoteServerVersion,
    Expression<int>? remoteServerRevision,
    Expression<String>? localCandidateJson,
    Expression<String>? remoteCandidateJson,
    Expression<int>? detectedAtUtc,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (mutationId != null) 'mutation_id': mutationId,
      if (baseServerVersion != null) 'base_server_version': baseServerVersion,
      if (remoteServerVersion != null)
        'remote_server_version': remoteServerVersion,
      if (remoteServerRevision != null)
        'remote_server_revision': remoteServerRevision,
      if (localCandidateJson != null)
        'local_candidate_json': localCandidateJson,
      if (remoteCandidateJson != null)
        'remote_candidate_json': remoteCandidateJson,
      if (detectedAtUtc != null) 'detected_at_utc': detectedAtUtc,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String?>? mutationId,
    Value<int>? baseServerVersion,
    Value<int>? remoteServerVersion,
    Value<int>? remoteServerRevision,
    Value<String>? localCandidateJson,
    Value<String>? remoteCandidateJson,
    Value<int>? detectedAtUtc,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      mutationId: mutationId ?? this.mutationId,
      baseServerVersion: baseServerVersion ?? this.baseServerVersion,
      remoteServerVersion: remoteServerVersion ?? this.remoteServerVersion,
      remoteServerRevision: remoteServerRevision ?? this.remoteServerRevision,
      localCandidateJson: localCandidateJson ?? this.localCandidateJson,
      remoteCandidateJson: remoteCandidateJson ?? this.remoteCandidateJson,
      detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (baseServerVersion.present) {
      map['base_server_version'] = Variable<int>(baseServerVersion.value);
    }
    if (remoteServerVersion.present) {
      map['remote_server_version'] = Variable<int>(remoteServerVersion.value);
    }
    if (remoteServerRevision.present) {
      map['remote_server_revision'] = Variable<int>(remoteServerRevision.value);
    }
    if (localCandidateJson.present) {
      map['local_candidate_json'] = Variable<String>(localCandidateJson.value);
    }
    if (remoteCandidateJson.present) {
      map['remote_candidate_json'] = Variable<String>(
        remoteCandidateJson.value,
      );
    }
    if (detectedAtUtc.present) {
      map['detected_at_utc'] = Variable<int>(detectedAtUtc.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('mutationId: $mutationId, ')
          ..write('baseServerVersion: $baseServerVersion, ')
          ..write('remoteServerVersion: $remoteServerVersion, ')
          ..write('remoteServerRevision: $remoteServerRevision, ')
          ..write('localCandidateJson: $localCandidateJson, ')
          ..write('remoteCandidateJson: $remoteCandidateJson, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncReceiptSpoolEntriesTable extends SyncReceiptSpoolEntries
    with TableInfo<$SyncReceiptSpoolEntriesTable, SyncReceiptSpoolEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncReceiptSpoolEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageKeyMeta = const VerificationMeta(
    'storageKey',
  );
  @override
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
    'storage_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256HexMeta = const VerificationMeta(
    'sha256Hex',
  );
  @override
  late final GeneratedColumn<String> sha256Hex = GeneratedColumn<String>(
    'sha256_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attachmentId,
    storageKey,
    sha256Hex,
    byteSize,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_receipt_spool_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncReceiptSpoolEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('storage_key')) {
      context.handle(
        _storageKeyMeta,
        storageKey.isAcceptableOrUnknown(data['storage_key']!, _storageKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_storageKeyMeta);
    }
    if (data.containsKey('sha256_hex')) {
      context.handle(
        _sha256HexMeta,
        sha256Hex.isAcceptableOrUnknown(data['sha256_hex']!, _sha256HexMeta),
      );
    } else if (isInserting) {
      context.missing(_sha256HexMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attachmentId};
  @override
  SyncReceiptSpoolEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncReceiptSpoolEntry(
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      )!,
      storageKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_key'],
      )!,
      sha256Hex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256_hex'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $SyncReceiptSpoolEntriesTable createAlias(String alias) {
    return $SyncReceiptSpoolEntriesTable(attachedDatabase, alias);
  }
}

class SyncReceiptSpoolEntry extends DataClass
    implements Insertable<SyncReceiptSpoolEntry> {
  final String attachmentId;
  final String storageKey;
  final String sha256Hex;
  final int byteSize;
  final int createdAtUtc;
  const SyncReceiptSpoolEntry({
    required this.attachmentId,
    required this.storageKey,
    required this.sha256Hex,
    required this.byteSize,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attachment_id'] = Variable<String>(attachmentId);
    map['storage_key'] = Variable<String>(storageKey);
    map['sha256_hex'] = Variable<String>(sha256Hex);
    map['byte_size'] = Variable<int>(byteSize);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  SyncReceiptSpoolEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncReceiptSpoolEntriesCompanion(
      attachmentId: Value(attachmentId),
      storageKey: Value(storageKey),
      sha256Hex: Value(sha256Hex),
      byteSize: Value(byteSize),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory SyncReceiptSpoolEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncReceiptSpoolEntry(
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      storageKey: serializer.fromJson<String>(json['storageKey']),
      sha256Hex: serializer.fromJson<String>(json['sha256Hex']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attachmentId': serializer.toJson<String>(attachmentId),
      'storageKey': serializer.toJson<String>(storageKey),
      'sha256Hex': serializer.toJson<String>(sha256Hex),
      'byteSize': serializer.toJson<int>(byteSize),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  SyncReceiptSpoolEntry copyWith({
    String? attachmentId,
    String? storageKey,
    String? sha256Hex,
    int? byteSize,
    int? createdAtUtc,
  }) => SyncReceiptSpoolEntry(
    attachmentId: attachmentId ?? this.attachmentId,
    storageKey: storageKey ?? this.storageKey,
    sha256Hex: sha256Hex ?? this.sha256Hex,
    byteSize: byteSize ?? this.byteSize,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  SyncReceiptSpoolEntry copyWithCompanion(
    SyncReceiptSpoolEntriesCompanion data,
  ) {
    return SyncReceiptSpoolEntry(
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      storageKey: data.storageKey.present
          ? data.storageKey.value
          : this.storageKey,
      sha256Hex: data.sha256Hex.present ? data.sha256Hex.value : this.sha256Hex,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncReceiptSpoolEntry(')
          ..write('attachmentId: $attachmentId, ')
          ..write('storageKey: $storageKey, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(attachmentId, storageKey, sha256Hex, byteSize, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncReceiptSpoolEntry &&
          other.attachmentId == this.attachmentId &&
          other.storageKey == this.storageKey &&
          other.sha256Hex == this.sha256Hex &&
          other.byteSize == this.byteSize &&
          other.createdAtUtc == this.createdAtUtc);
}

class SyncReceiptSpoolEntriesCompanion
    extends UpdateCompanion<SyncReceiptSpoolEntry> {
  final Value<String> attachmentId;
  final Value<String> storageKey;
  final Value<String> sha256Hex;
  final Value<int> byteSize;
  final Value<int> createdAtUtc;
  final Value<int> rowid;
  const SyncReceiptSpoolEntriesCompanion({
    this.attachmentId = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncReceiptSpoolEntriesCompanion.insert({
    required String attachmentId,
    required String storageKey,
    required String sha256Hex,
    required int byteSize,
    required int createdAtUtc,
    this.rowid = const Value.absent(),
  }) : attachmentId = Value(attachmentId),
       storageKey = Value(storageKey),
       sha256Hex = Value(sha256Hex),
       byteSize = Value(byteSize),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<SyncReceiptSpoolEntry> custom({
    Expression<String>? attachmentId,
    Expression<String>? storageKey,
    Expression<String>? sha256Hex,
    Expression<int>? byteSize,
    Expression<int>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (storageKey != null) 'storage_key': storageKey,
      if (sha256Hex != null) 'sha256_hex': sha256Hex,
      if (byteSize != null) 'byte_size': byteSize,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncReceiptSpoolEntriesCompanion copyWith({
    Value<String>? attachmentId,
    Value<String>? storageKey,
    Value<String>? sha256Hex,
    Value<int>? byteSize,
    Value<int>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return SyncReceiptSpoolEntriesCompanion(
      attachmentId: attachmentId ?? this.attachmentId,
      storageKey: storageKey ?? this.storageKey,
      sha256Hex: sha256Hex ?? this.sha256Hex,
      byteSize: byteSize ?? this.byteSize,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (sha256Hex.present) {
      map['sha256_hex'] = Variable<String>(sha256Hex.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncReceiptSpoolEntriesCompanion(')
          ..write('attachmentId: $attachmentId, ')
          ..write('storageKey: $storageKey, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncAttachmentCleanupTable extends SyncAttachmentCleanup
    with TableInfo<$SyncAttachmentCleanupTable, SyncAttachmentCleanupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncAttachmentCleanupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtUtcMeta = const VerificationMeta(
    'nextAttemptAtUtc',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAtUtc = GeneratedColumn<int>(
    'next_attempt_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    storagePath,
    attemptCount,
    nextAttemptAtUtc,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_attachment_cleanup';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncAttachmentCleanupData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at_utc')) {
      context.handle(
        _nextAttemptAtUtcMeta,
        nextAttemptAtUtc.isAcceptableOrUnknown(
          data['next_attempt_at_utc']!,
          _nextAttemptAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {storagePath};
  @override
  SyncAttachmentCleanupData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncAttachmentCleanupData(
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at_utc'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $SyncAttachmentCleanupTable createAlias(String alias) {
    return $SyncAttachmentCleanupTable(attachedDatabase, alias);
  }
}

class SyncAttachmentCleanupData extends DataClass
    implements Insertable<SyncAttachmentCleanupData> {
  final String storagePath;
  final int attemptCount;
  final int? nextAttemptAtUtc;
  final int createdAtUtc;
  const SyncAttachmentCleanupData({
    required this.storagePath,
    required this.attemptCount,
    this.nextAttemptAtUtc,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['storage_path'] = Variable<String>(storagePath);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAtUtc != null) {
      map['next_attempt_at_utc'] = Variable<int>(nextAttemptAtUtc);
    }
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  SyncAttachmentCleanupCompanion toCompanion(bool nullToAbsent) {
    return SyncAttachmentCleanupCompanion(
      storagePath: Value(storagePath),
      attemptCount: Value(attemptCount),
      nextAttemptAtUtc: nextAttemptAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAtUtc),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory SyncAttachmentCleanupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncAttachmentCleanupData(
      storagePath: serializer.fromJson<String>(json['storagePath']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAtUtc: serializer.fromJson<int?>(json['nextAttemptAtUtc']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storagePath': serializer.toJson<String>(storagePath),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAtUtc': serializer.toJson<int?>(nextAttemptAtUtc),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  SyncAttachmentCleanupData copyWith({
    String? storagePath,
    int? attemptCount,
    Value<int?> nextAttemptAtUtc = const Value.absent(),
    int? createdAtUtc,
  }) => SyncAttachmentCleanupData(
    storagePath: storagePath ?? this.storagePath,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAtUtc: nextAttemptAtUtc.present
        ? nextAttemptAtUtc.value
        : this.nextAttemptAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  SyncAttachmentCleanupData copyWithCompanion(
    SyncAttachmentCleanupCompanion data,
  ) {
    return SyncAttachmentCleanupData(
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAtUtc: data.nextAttemptAtUtc.present
          ? data.nextAttemptAtUtc.value
          : this.nextAttemptAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncAttachmentCleanupData(')
          ..write('storagePath: $storagePath, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAtUtc: $nextAttemptAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(storagePath, attemptCount, nextAttemptAtUtc, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncAttachmentCleanupData &&
          other.storagePath == this.storagePath &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAtUtc == this.nextAttemptAtUtc &&
          other.createdAtUtc == this.createdAtUtc);
}

class SyncAttachmentCleanupCompanion
    extends UpdateCompanion<SyncAttachmentCleanupData> {
  final Value<String> storagePath;
  final Value<int> attemptCount;
  final Value<int?> nextAttemptAtUtc;
  final Value<int> createdAtUtc;
  final Value<int> rowid;
  const SyncAttachmentCleanupCompanion({
    this.storagePath = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncAttachmentCleanupCompanion.insert({
    required String storagePath,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAtUtc = const Value.absent(),
    required int createdAtUtc,
    this.rowid = const Value.absent(),
  }) : storagePath = Value(storagePath),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<SyncAttachmentCleanupData> custom({
    Expression<String>? storagePath,
    Expression<int>? attemptCount,
    Expression<int>? nextAttemptAtUtc,
    Expression<int>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storagePath != null) 'storage_path': storagePath,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAtUtc != null) 'next_attempt_at_utc': nextAttemptAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncAttachmentCleanupCompanion copyWith({
    Value<String>? storagePath,
    Value<int>? attemptCount,
    Value<int?>? nextAttemptAtUtc,
    Value<int>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return SyncAttachmentCleanupCompanion(
      storagePath: storagePath ?? this.storagePath,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAtUtc: nextAttemptAtUtc ?? this.nextAttemptAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAtUtc.present) {
      map['next_attempt_at_utc'] = Variable<int>(nextAttemptAtUtc.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncAttachmentCleanupCompanion(')
          ..write('storagePath: $storagePath, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAtUtc: $nextAttemptAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOnboardingStatesTable extends SyncOnboardingStates
    with TableInfo<$SyncOnboardingStatesTable, SyncOnboardingState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOnboardingStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datasetGenerationMeta = const VerificationMeta(
    'datasetGeneration',
  );
  @override
  late final GeneratedColumn<String> datasetGeneration =
      GeneratedColumn<String>(
        'dataset_generation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idle'),
  );
  static const VerificationMeta _initializationOperationIdMeta =
      const VerificationMeta('initializationOperationId');
  @override
  late final GeneratedColumn<String> initializationOperationId =
      GeneratedColumn<String>(
        'initialization_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSuccessfulSyncAtUtcMeta =
      const VerificationMeta('lastSuccessfulSyncAtUtc');
  @override
  late final GeneratedColumn<int> lastSuccessfulSyncAtUtc =
      GeneratedColumn<int>(
        'last_successful_sync_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slot,
    datasetGeneration,
    stage,
    initializationOperationId,
    paused,
    lastSuccessfulSyncAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_onboarding_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOnboardingState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('dataset_generation')) {
      context.handle(
        _datasetGenerationMeta,
        datasetGeneration.isAcceptableOrUnknown(
          data['dataset_generation']!,
          _datasetGenerationMeta,
        ),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('initialization_operation_id')) {
      context.handle(
        _initializationOperationIdMeta,
        initializationOperationId.isAcceptableOrUnknown(
          data['initialization_operation_id']!,
          _initializationOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
      );
    }
    if (data.containsKey('last_successful_sync_at_utc')) {
      context.handle(
        _lastSuccessfulSyncAtUtcMeta,
        lastSuccessfulSyncAtUtc.isAcceptableOrUnknown(
          data['last_successful_sync_at_utc']!,
          _lastSuccessfulSyncAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  SyncOnboardingState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOnboardingState(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      datasetGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_generation'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      initializationOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initialization_operation_id'],
      ),
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paused'],
      )!,
      lastSuccessfulSyncAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_successful_sync_at_utc'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $SyncOnboardingStatesTable createAlias(String alias) {
    return $SyncOnboardingStatesTable(attachedDatabase, alias);
  }
}

class SyncOnboardingState extends DataClass
    implements Insertable<SyncOnboardingState> {
  final int slot;
  final String? datasetGeneration;
  final String stage;
  final String? initializationOperationId;
  final bool paused;
  final int? lastSuccessfulSyncAtUtc;
  final int updatedAtUtc;
  const SyncOnboardingState({
    required this.slot,
    this.datasetGeneration,
    required this.stage,
    this.initializationOperationId,
    required this.paused,
    this.lastSuccessfulSyncAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    if (!nullToAbsent || datasetGeneration != null) {
      map['dataset_generation'] = Variable<String>(datasetGeneration);
    }
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || initializationOperationId != null) {
      map['initialization_operation_id'] = Variable<String>(
        initializationOperationId,
      );
    }
    map['paused'] = Variable<bool>(paused);
    if (!nullToAbsent || lastSuccessfulSyncAtUtc != null) {
      map['last_successful_sync_at_utc'] = Variable<int>(
        lastSuccessfulSyncAtUtc,
      );
    }
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  SyncOnboardingStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncOnboardingStatesCompanion(
      slot: Value(slot),
      datasetGeneration: datasetGeneration == null && nullToAbsent
          ? const Value.absent()
          : Value(datasetGeneration),
      stage: Value(stage),
      initializationOperationId:
          initializationOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(initializationOperationId),
      paused: Value(paused),
      lastSuccessfulSyncAtUtc: lastSuccessfulSyncAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulSyncAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory SyncOnboardingState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOnboardingState(
      slot: serializer.fromJson<int>(json['slot']),
      datasetGeneration: serializer.fromJson<String?>(
        json['datasetGeneration'],
      ),
      stage: serializer.fromJson<String>(json['stage']),
      initializationOperationId: serializer.fromJson<String?>(
        json['initializationOperationId'],
      ),
      paused: serializer.fromJson<bool>(json['paused']),
      lastSuccessfulSyncAtUtc: serializer.fromJson<int?>(
        json['lastSuccessfulSyncAtUtc'],
      ),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'datasetGeneration': serializer.toJson<String?>(datasetGeneration),
      'stage': serializer.toJson<String>(stage),
      'initializationOperationId': serializer.toJson<String?>(
        initializationOperationId,
      ),
      'paused': serializer.toJson<bool>(paused),
      'lastSuccessfulSyncAtUtc': serializer.toJson<int?>(
        lastSuccessfulSyncAtUtc,
      ),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  SyncOnboardingState copyWith({
    int? slot,
    Value<String?> datasetGeneration = const Value.absent(),
    String? stage,
    Value<String?> initializationOperationId = const Value.absent(),
    bool? paused,
    Value<int?> lastSuccessfulSyncAtUtc = const Value.absent(),
    int? updatedAtUtc,
  }) => SyncOnboardingState(
    slot: slot ?? this.slot,
    datasetGeneration: datasetGeneration.present
        ? datasetGeneration.value
        : this.datasetGeneration,
    stage: stage ?? this.stage,
    initializationOperationId: initializationOperationId.present
        ? initializationOperationId.value
        : this.initializationOperationId,
    paused: paused ?? this.paused,
    lastSuccessfulSyncAtUtc: lastSuccessfulSyncAtUtc.present
        ? lastSuccessfulSyncAtUtc.value
        : this.lastSuccessfulSyncAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  SyncOnboardingState copyWithCompanion(SyncOnboardingStatesCompanion data) {
    return SyncOnboardingState(
      slot: data.slot.present ? data.slot.value : this.slot,
      datasetGeneration: data.datasetGeneration.present
          ? data.datasetGeneration.value
          : this.datasetGeneration,
      stage: data.stage.present ? data.stage.value : this.stage,
      initializationOperationId: data.initializationOperationId.present
          ? data.initializationOperationId.value
          : this.initializationOperationId,
      paused: data.paused.present ? data.paused.value : this.paused,
      lastSuccessfulSyncAtUtc: data.lastSuccessfulSyncAtUtc.present
          ? data.lastSuccessfulSyncAtUtc.value
          : this.lastSuccessfulSyncAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOnboardingState(')
          ..write('slot: $slot, ')
          ..write('datasetGeneration: $datasetGeneration, ')
          ..write('stage: $stage, ')
          ..write('initializationOperationId: $initializationOperationId, ')
          ..write('paused: $paused, ')
          ..write('lastSuccessfulSyncAtUtc: $lastSuccessfulSyncAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slot,
    datasetGeneration,
    stage,
    initializationOperationId,
    paused,
    lastSuccessfulSyncAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOnboardingState &&
          other.slot == this.slot &&
          other.datasetGeneration == this.datasetGeneration &&
          other.stage == this.stage &&
          other.initializationOperationId == this.initializationOperationId &&
          other.paused == this.paused &&
          other.lastSuccessfulSyncAtUtc == this.lastSuccessfulSyncAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class SyncOnboardingStatesCompanion
    extends UpdateCompanion<SyncOnboardingState> {
  final Value<int> slot;
  final Value<String?> datasetGeneration;
  final Value<String> stage;
  final Value<String?> initializationOperationId;
  final Value<bool> paused;
  final Value<int?> lastSuccessfulSyncAtUtc;
  final Value<int> updatedAtUtc;
  const SyncOnboardingStatesCompanion({
    this.slot = const Value.absent(),
    this.datasetGeneration = const Value.absent(),
    this.stage = const Value.absent(),
    this.initializationOperationId = const Value.absent(),
    this.paused = const Value.absent(),
    this.lastSuccessfulSyncAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  SyncOnboardingStatesCompanion.insert({
    this.slot = const Value.absent(),
    this.datasetGeneration = const Value.absent(),
    this.stage = const Value.absent(),
    this.initializationOperationId = const Value.absent(),
    this.paused = const Value.absent(),
    this.lastSuccessfulSyncAtUtc = const Value.absent(),
    required int updatedAtUtc,
  }) : updatedAtUtc = Value(updatedAtUtc);
  static Insertable<SyncOnboardingState> custom({
    Expression<int>? slot,
    Expression<String>? datasetGeneration,
    Expression<String>? stage,
    Expression<String>? initializationOperationId,
    Expression<bool>? paused,
    Expression<int>? lastSuccessfulSyncAtUtc,
    Expression<int>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (datasetGeneration != null) 'dataset_generation': datasetGeneration,
      if (stage != null) 'stage': stage,
      if (initializationOperationId != null)
        'initialization_operation_id': initializationOperationId,
      if (paused != null) 'paused': paused,
      if (lastSuccessfulSyncAtUtc != null)
        'last_successful_sync_at_utc': lastSuccessfulSyncAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  SyncOnboardingStatesCompanion copyWith({
    Value<int>? slot,
    Value<String?>? datasetGeneration,
    Value<String>? stage,
    Value<String?>? initializationOperationId,
    Value<bool>? paused,
    Value<int?>? lastSuccessfulSyncAtUtc,
    Value<int>? updatedAtUtc,
  }) {
    return SyncOnboardingStatesCompanion(
      slot: slot ?? this.slot,
      datasetGeneration: datasetGeneration ?? this.datasetGeneration,
      stage: stage ?? this.stage,
      initializationOperationId:
          initializationOperationId ?? this.initializationOperationId,
      paused: paused ?? this.paused,
      lastSuccessfulSyncAtUtc:
          lastSuccessfulSyncAtUtc ?? this.lastSuccessfulSyncAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (datasetGeneration.present) {
      map['dataset_generation'] = Variable<String>(datasetGeneration.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (initializationOperationId.present) {
      map['initialization_operation_id'] = Variable<String>(
        initializationOperationId.value,
      );
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (lastSuccessfulSyncAtUtc.present) {
      map['last_successful_sync_at_utc'] = Variable<int>(
        lastSuccessfulSyncAtUtc.value,
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOnboardingStatesCompanion(')
          ..write('slot: $slot, ')
          ..write('datasetGeneration: $datasetGeneration, ')
          ..write('stage: $stage, ')
          ..write('initializationOperationId: $initializationOperationId, ')
          ..write('paused: $paused, ')
          ..write('lastSuccessfulSyncAtUtc: $lastSuccessfulSyncAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SyncInitializationEntitiesTable extends SyncInitializationEntities
    with TableInfo<$SyncInitializationEntitiesTable, SyncInitializationEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncInitializationEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ordinal,
    entityType,
    entityId,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_initialization_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncInitializationEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ordinal};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entityType, entityId},
  ];
  @override
  SyncInitializationEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncInitializationEntity(
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $SyncInitializationEntitiesTable createAlias(String alias) {
    return $SyncInitializationEntitiesTable(attachedDatabase, alias);
  }
}

class SyncInitializationEntity extends DataClass
    implements Insertable<SyncInitializationEntity> {
  final int ordinal;
  final String entityType;
  final String entityId;
  final String payloadJson;
  const SyncInitializationEntity({
    required this.ordinal,
    required this.entityType,
    required this.entityId,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ordinal'] = Variable<int>(ordinal);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  SyncInitializationEntitiesCompanion toCompanion(bool nullToAbsent) {
    return SyncInitializationEntitiesCompanion(
      ordinal: Value(ordinal),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
    );
  }

  factory SyncInitializationEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncInitializationEntity(
      ordinal: serializer.fromJson<int>(json['ordinal']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ordinal': serializer.toJson<int>(ordinal),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  SyncInitializationEntity copyWith({
    int? ordinal,
    String? entityType,
    String? entityId,
    String? payloadJson,
  }) => SyncInitializationEntity(
    ordinal: ordinal ?? this.ordinal,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  SyncInitializationEntity copyWithCompanion(
    SyncInitializationEntitiesCompanion data,
  ) {
    return SyncInitializationEntity(
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncInitializationEntity(')
          ..write('ordinal: $ordinal, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ordinal, entityType, entityId, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncInitializationEntity &&
          other.ordinal == this.ordinal &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson);
}

class SyncInitializationEntitiesCompanion
    extends UpdateCompanion<SyncInitializationEntity> {
  final Value<int> ordinal;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payloadJson;
  const SyncInitializationEntitiesCompanion({
    this.ordinal = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
  });
  SyncInitializationEntitiesCompanion.insert({
    this.ordinal = const Value.absent(),
    required String entityType,
    required String entityId,
    required String payloadJson,
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       payloadJson = Value(payloadJson);
  static Insertable<SyncInitializationEntity> custom({
    Expression<int>? ordinal,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
  }) {
    return RawValuesInsertable({
      if (ordinal != null) 'ordinal': ordinal,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
    });
  }

  SyncInitializationEntitiesCompanion copyWith({
    Value<int>? ordinal,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? payloadJson,
  }) {
    return SyncInitializationEntitiesCompanion(
      ordinal: ordinal ?? this.ordinal,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncInitializationEntitiesCompanion(')
          ..write('ordinal: $ordinal, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$LedgerDatabase extends GeneratedDatabase {
  _$LedgerDatabase(QueryExecutor e) : super(e);
  $LedgerDatabaseManager get managers => $LedgerDatabaseManager(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $BookkeepingTransactionsTable bookkeepingTransactions =
      $BookkeepingTransactionsTable(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  late final $ReceiptAttachmentsTable receiptAttachments =
      $ReceiptAttachmentsTable(this);
  late final $SyncLinkStatesTable syncLinkStates = $SyncLinkStatesTable(this);
  late final $SyncDeviceStatesTable syncDeviceStates = $SyncDeviceStatesTable(
    this,
  );
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncEntityStatesTable syncEntityStates = $SyncEntityStatesTable(
    this,
  );
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncReceiptSpoolEntriesTable syncReceiptSpoolEntries =
      $SyncReceiptSpoolEntriesTable(this);
  late final $SyncAttachmentCleanupTable syncAttachmentCleanup =
      $SyncAttachmentCleanupTable(this);
  late final $SyncOnboardingStatesTable syncOnboardingStates =
      $SyncOnboardingStatesTable(this);
  late final $SyncInitializationEntitiesTable syncInitializationEntities =
      $SyncInitializationEntitiesTable(this);
  late final Index historyProfileDateId = Index(
    'history_profile_date_id',
    'CREATE INDEX history_profile_date_id ON bookkeeping_transactions (profile_id, business_date, id)',
  );
  late final Index transferProfileDateId = Index(
    'transfer_profile_date_id',
    'CREATE INDEX transfer_profile_date_id ON transfers (profile_id, business_date, id)',
  );
  late final Index receiptTransactionPosition = Index(
    'receipt_transaction_position',
    'CREATE UNIQUE INDEX receipt_transaction_position ON receipt_attachments (transaction_id, position)',
  );
  late final Index syncOutboxQueue = Index(
    'sync_outbox_queue',
    'CREATE INDEX sync_outbox_queue ON sync_outbox (queue_sequence)',
  );
  late final Index syncOutboxEntityQueue = Index(
    'sync_outbox_entity_queue',
    'CREATE INDEX sync_outbox_entity_queue ON sync_outbox (entity_type, entity_id, queue_sequence)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProfiles,
    accounts,
    categories,
    projects,
    budgets,
    bookkeepingTransactions,
    transfers,
    receiptAttachments,
    syncLinkStates,
    syncDeviceStates,
    syncCursors,
    syncEntityStates,
    syncOutbox,
    syncConflicts,
    syncReceiptSpoolEntries,
    syncAttachmentCleanup,
    syncOnboardingStates,
    syncInitializationEntities,
    historyProfileDateId,
    transferProfileDateId,
    receiptTransactionPosition,
    syncOutboxQueue,
    syncOutboxEntityQueue,
  ];
}

typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<int> slot,
      required String id,
      required String baseCurrencyCode,
      required int createdAtUtc,
      required int updatedAtUtc,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<int> slot,
      Value<String> id,
      Value<String> baseCurrencyCode,
      Value<int> createdAtUtc,
      Value<int> updatedAtUtc,
    });

final class $$LocalProfilesTableReferences
    extends
        BaseReferences<_$LedgerDatabase, $LocalProfilesTable, LocalProfile> {
  $$LocalProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AccountsTable, List<Account>> _accountsRefsTable(
    _$LedgerDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'local_profiles__id__accounts__profile_id',
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoriesTable, List<Category>>
  _categoriesRefsTable(_$LedgerDatabase db) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: 'local_profiles__id__categories__profile_id',
  );

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$LedgerDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: 'local_profiles__id__projects__profile_id',
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$LedgerDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: 'local_profiles__id__budgets__profile_id',
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BookkeepingTransactionsTable,
    List<BookkeepingTransaction>
  >
  _bookkeepingTransactionsRefsTable(_$LedgerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.bookkeepingTransactions,
        aliasName: 'local_profiles__id__bookkeeping_transactions__profile_id',
      );

  $$BookkeepingTransactionsTableProcessedTableManager
  get bookkeepingTransactionsRefs {
    final manager = $$BookkeepingTransactionsTableTableManager(
      $_db,
      $_db.bookkeepingTransactions,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _bookkeepingTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _transfersRefsTable(_$LedgerDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: 'local_profiles__id__transfers__profile_id',
  );

  $$TransfersTableProcessedTableManager get transfersRefs {
    final manager = $$TransfersTableTableManager(
      $_db,
      $_db.transfers,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transfersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReceiptAttachmentsTable, List<ReceiptAttachment>>
  _receiptAttachmentsRefsTable(_$LedgerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.receiptAttachments,
        aliasName: 'local_profiles__id__receipt_attachments__profile_id',
      );

  $$ReceiptAttachmentsTableProcessedTableManager get receiptAttachmentsRefs {
    final manager = $$ReceiptAttachmentsTableTableManager(
      $_db,
      $_db.receiptAttachments,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receiptAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalProfilesTableFilterComposer
    extends Composer<_$LedgerDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoriesRefs(
    Expression<bool> Function($$CategoriesTableFilterComposer f) f,
  ) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookkeepingTransactionsRefs(
    Expression<bool> Function($$BookkeepingTransactionsTableFilterComposer f) f,
  ) {
    final $$BookkeepingTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> transfersRefs(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receiptAttachmentsRefs(
    Expression<bool> Function($$ReceiptAttachmentsTableFilterComposer f) f,
  ) {
    final $$ReceiptAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptAttachments,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.receiptAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($$CategoriesTableAnnotationComposer a) f,
  ) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookkeepingTransactionsRefs<T extends Object>(
    Expression<T> Function($$BookkeepingTransactionsTableAnnotationComposer a)
    f,
  ) {
    final $$BookkeepingTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transfersRefs<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receiptAttachmentsRefs<T extends Object>(
    Expression<T> Function($$ReceiptAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.receiptAttachments,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReceiptAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.receiptAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (LocalProfile, $$LocalProfilesTableReferences),
          LocalProfile,
          PrefetchHooks Function({
            bool accountsRefs,
            bool categoriesRefs,
            bool projectsRefs,
            bool budgetsRefs,
            bool bookkeepingTransactionsRefs,
            bool transfersRefs,
            bool receiptAttachmentsRefs,
          })
        > {
  $$LocalProfilesTableTableManager(
    _$LedgerDatabase db,
    $LocalProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> baseCurrencyCode = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
              }) => LocalProfilesCompanion(
                slot: slot,
                id: id,
                baseCurrencyCode: baseCurrencyCode,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                required String id,
                required String baseCurrencyCode,
                required int createdAtUtc,
                required int updatedAtUtc,
              }) => LocalProfilesCompanion.insert(
                slot: slot,
                id: id,
                baseCurrencyCode: baseCurrencyCode,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProfilesTable, LocalProfile>(table),
                  $$LocalProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountsRefs = false,
                categoriesRefs = false,
                projectsRefs = false,
                budgetsRefs = false,
                bookkeepingTransactionsRefs = false,
                transfersRefs = false,
                receiptAttachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountsRefs) db.accounts,
                    if (categoriesRefs) db.categories,
                    if (projectsRefs) db.projects,
                    if (budgetsRefs) db.budgets,
                    if (bookkeepingTransactionsRefs) db.bookkeepingTransactions,
                    if (transfersRefs) db.transfers,
                    if (receiptAttachmentsRefs) db.receiptAttachments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountsRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          Account
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._accountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).accountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoriesRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          Category
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (projectsRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          Project
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookkeepingTransactionsRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          BookkeepingTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._bookkeepingTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).bookkeepingTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transfersRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._transfersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).transfersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (receiptAttachmentsRefs)
                        await $_getPrefetchedData<
                          LocalProfile,
                          $LocalProfilesTable,
                          ReceiptAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._receiptAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (LocalProfile, $$LocalProfilesTableReferences),
      LocalProfile,
      PrefetchHooks Function({
        bool accountsRefs,
        bool categoriesRefs,
        bool projectsRefs,
        bool budgetsRefs,
        bool bookkeepingTransactionsRefs,
        bool transfersRefs,
        bool receiptAttachmentsRefs,
      })
    >;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String profileId,
  required String name,
  required String kind,
  required String currencyCode,
  required int openingMinorUnits,
  required String openingDate,
  Value<bool> isArchived,
  required int createdAtUtc,
  required int updatedAtUtc,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> name,
  Value<String> kind,
  Value<String> currencyCode,
  Value<int> openingMinorUnits,
  Value<String> openingDate,
  Value<bool> isArchived,
  Value<int> createdAtUtc,
  Value<int> updatedAtUtc,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$LedgerDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) =>
      db.localProfiles.createAlias('accounts__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $BookkeepingTransactionsTable,
    List<BookkeepingTransaction>
  >
  _bookkeepingTransactionsRefsTable(_$LedgerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.bookkeepingTransactions,
        aliasName: 'accounts__id__bookkeeping_transactions__account_id',
      );

  $$BookkeepingTransactionsTableProcessedTableManager
  get bookkeepingTransactionsRefs {
    final manager = $$BookkeepingTransactionsTableTableManager(
      $_db,
      $_db.bookkeepingTransactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _bookkeepingTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _outgoingTransfersTable(_$LedgerDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: 'accounts__id__transfers__source_account_id',
  );

  $$TransfersTableProcessedTableManager get outgoingTransfers {
    final manager = $$TransfersTableTableManager($_db, $_db.transfers).filter(
      (f) => f.sourceAccountId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_outgoingTransfersTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _incomingTransfersTable(_$LedgerDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: 'accounts__id__transfers__destination_account_id',
  );

  $$TransfersTableProcessedTableManager get incomingTransfers {
    final manager = $$TransfersTableTableManager($_db, $_db.transfers).filter(
      (f) => f.destinationAccountId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_incomingTransfersTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$LedgerDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingMinorUnits => $composableBuilder(
    column: $table.openingMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingDate => $composableBuilder(
    column: $table.openingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookkeepingTransactionsRefs(
    Expression<bool> Function($$BookkeepingTransactionsTableFilterComposer f) f,
  ) {
    final $$BookkeepingTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> outgoingTransfers(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.sourceAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingTransfers(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.destinationAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingMinorUnits => $composableBuilder(
    column: $table.openingMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingDate => $composableBuilder(
    column: $table.openingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openingMinorUnits => $composableBuilder(
    column: $table.openingMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openingDate => $composableBuilder(
    column: $table.openingDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookkeepingTransactionsRefs<T extends Object>(
    Expression<T> Function($$BookkeepingTransactionsTableAnnotationComposer a)
    f,
  ) {
    final $$BookkeepingTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> outgoingTransfers<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.sourceAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomingTransfers<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.destinationAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool profileId,
            bool bookkeepingTransactionsRefs,
            bool outgoingTransfers,
            bool incomingTransfers,
          })
        > {
  $$AccountsTableTableManager(_$LedgerDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> openingMinorUnits = const Value.absent(),
                Value<String> openingDate = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                kind: kind,
                currencyCode: currencyCode,
                openingMinorUnits: openingMinorUnits,
                openingDate: openingDate,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                required String kind,
                required String currencyCode,
                required int openingMinorUnits,
                required String openingDate,
                Value<bool> isArchived = const Value.absent(),
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                kind: kind,
                currencyCode: currencyCode,
                openingMinorUnits: openingMinorUnits,
                openingDate: openingDate,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                bookkeepingTransactionsRefs = false,
                outgoingTransfers = false,
                incomingTransfers = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookkeepingTransactionsRefs) db.bookkeepingTransactions,
                    if (outgoingTransfers) db.transfers,
                    if (incomingTransfers) db.transfers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$AccountsTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$AccountsTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookkeepingTransactionsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          BookkeepingTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._bookkeepingTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).bookkeepingTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outgoingTransfers)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._outgoingTransfersTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).outgoingTransfers,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomingTransfers)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._incomingTransfersTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingTransfers,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.destinationAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool profileId,
        bool bookkeepingTransactionsRefs,
        bool outgoingTransfers,
        bool incomingTransfers,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String profileId,
  required String name,
  required String kind,
  Value<bool> isArchived,
  required int createdAtUtc,
  required int updatedAtUtc,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> name,
  Value<String> kind,
  Value<bool> isArchived,
  Value<int> createdAtUtc,
  Value<int> updatedAtUtc,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$LedgerDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) => db
      .localProfiles
      .createAlias('categories__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$LedgerDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: 'categories__id__budgets__category_id',
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BookkeepingTransactionsTable,
    List<BookkeepingTransaction>
  >
  _bookkeepingTransactionsRefsTable(_$LedgerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.bookkeepingTransactions,
        aliasName: 'categories__id__bookkeeping_transactions__category_id',
      );

  $$BookkeepingTransactionsTableProcessedTableManager
  get bookkeepingTransactionsRefs {
    final manager = $$BookkeepingTransactionsTableTableManager(
      $_db,
      $_db.bookkeepingTransactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _bookkeepingTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$LedgerDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookkeepingTransactionsRefs(
    Expression<bool> Function($$BookkeepingTransactionsTableFilterComposer f) f,
  ) {
    final $$BookkeepingTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookkeepingTransactionsRefs<T extends Object>(
    Expression<T> Function($$BookkeepingTransactionsTableAnnotationComposer a)
    f,
  ) {
    final $$BookkeepingTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool profileId,
            bool budgetsRefs,
            bool bookkeepingTransactionsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$LedgerDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                profileId: profileId,
                name: name,
                kind: kind,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                required String kind,
                Value<bool> isArchived = const Value.absent(),
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                kind: kind,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                budgetsRefs = false,
                bookkeepingTransactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (budgetsRefs) db.budgets,
                    if (bookkeepingTransactionsRefs) db.bookkeepingTransactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$CategoriesTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$CategoriesTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookkeepingTransactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          BookkeepingTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._bookkeepingTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).bookkeepingTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool profileId,
        bool budgetsRefs,
        bool bookkeepingTransactionsRefs,
      })
    >;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required String profileId,
  required String name,
  Value<String?> description,
  Value<bool> isArchived,
  required int createdAtUtc,
  required int updatedAtUtc,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> name,
  Value<String?> description,
  Value<bool> isArchived,
  Value<int> createdAtUtc,
  Value<int> updatedAtUtc,
  Value<int> rowid,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$LedgerDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) =>
      db.localProfiles.createAlias('projects__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $BookkeepingTransactionsTable,
    List<BookkeepingTransaction>
  >
  _bookkeepingTransactionsRefsTable(_$LedgerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.bookkeepingTransactions,
        aliasName: 'projects__id__bookkeeping_transactions__project_id',
      );

  $$BookkeepingTransactionsTableProcessedTableManager
  get bookkeepingTransactionsRefs {
    final manager = $$BookkeepingTransactionsTableTableManager(
      $_db,
      $_db.bookkeepingTransactions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _bookkeepingTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$LedgerDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookkeepingTransactionsRefs(
    Expression<bool> Function($$BookkeepingTransactionsTableFilterComposer f) f,
  ) {
    final $$BookkeepingTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookkeepingTransactionsRefs<T extends Object>(
    Expression<T> Function($$BookkeepingTransactionsTableAnnotationComposer a)
    f,
  ) {
    final $$BookkeepingTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool profileId,
            bool bookkeepingTransactionsRefs,
          })
        > {
  $$ProjectsTableTableManager(_$LedgerDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, Project>(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, bookkeepingTransactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookkeepingTransactionsRefs) db.bookkeepingTransactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$ProjectsTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$ProjectsTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookkeepingTransactionsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          BookkeepingTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._bookkeepingTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).bookkeepingTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool profileId, bool bookkeepingTransactionsRefs})
    >;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String profileId,
  required String name,
  required int amountMinorUnits,
  required String currencyCode,
  required String month,
  Value<String?> categoryId,
  Value<int> warningThresholdPercent,
  Value<bool> isArchived,
  required int createdAtUtc,
  required int updatedAtUtc,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> name,
  Value<int> amountMinorUnits,
  Value<String> currencyCode,
  Value<String> month,
  Value<String?> categoryId,
  Value<int> warningThresholdPercent,
  Value<bool> isArchived,
  Value<int> createdAtUtc,
  Value<int> updatedAtUtc,
  Value<int> rowid,
});

final class $$BudgetsTableReferences
    extends BaseReferences<_$LedgerDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) =>
      db.localProfiles.createAlias('budgets__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$LedgerDatabase db) =>
      db.categories.createAlias('budgets__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$LedgerDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningThresholdPercent => $composableBuilder(
    column: $table.warningThresholdPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningThresholdPercent => $composableBuilder(
    column: $table.warningThresholdPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get warningThresholdPercent => $composableBuilder(
    column: $table.warningThresholdPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool profileId, bool categoryId})
        > {
  $$BudgetsTableTableManager(_$LedgerDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> warningThresholdPercent = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                month: month,
                categoryId: categoryId,
                warningThresholdPercent: warningThresholdPercent,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                required int amountMinorUnits,
                required String currencyCode,
                required String month,
                Value<String?> categoryId = const Value.absent(),
                Value<int> warningThresholdPercent = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                month: month,
                categoryId: categoryId,
                warningThresholdPercent: warningThresholdPercent,
                isArchived: isArchived,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, Budget>(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$BudgetsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$BudgetsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$BudgetsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$BudgetsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool profileId, bool categoryId})
    >;
typedef $$BookkeepingTransactionsTableCreateCompanionBuilder =
    BookkeepingTransactionsCompanion Function({
      required String id,
      required String profileId,
      required String accountId,
      required String categoryId,
      Value<String?> projectId,
      required String kind,
      required int amountMinorUnits,
      required String currencyCode,
      required String businessDate,
      Value<String?> note,
      required int createdAtUtc,
      required int updatedAtUtc,
      Value<int?> deletedAtUtc,
      Value<int> rowid,
    });
typedef $$BookkeepingTransactionsTableUpdateCompanionBuilder =
    BookkeepingTransactionsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> accountId,
      Value<String> categoryId,
      Value<String?> projectId,
      Value<String> kind,
      Value<int> amountMinorUnits,
      Value<String> currencyCode,
      Value<String> businessDate,
      Value<String?> note,
      Value<int> createdAtUtc,
      Value<int> updatedAtUtc,
      Value<int?> deletedAtUtc,
      Value<int> rowid,
    });

final class $$BookkeepingTransactionsTableReferences
    extends
        BaseReferences<
          _$LedgerDatabase,
          $BookkeepingTransactionsTable,
          BookkeepingTransaction
        > {
  $$BookkeepingTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) => db
      .localProfiles
      .createAlias('bookkeeping_transactions__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$LedgerDatabase db) => db.accounts
      .createAlias('bookkeeping_transactions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$LedgerDatabase db) => db.categories
      .createAlias('bookkeeping_transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$LedgerDatabase db) => db.projects
      .createAlias('bookkeeping_transactions__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReceiptAttachmentsTable, List<ReceiptAttachment>>
  _receiptAttachmentsRefsTable(_$LedgerDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.receiptAttachments,
        aliasName:
            'bookkeeping_transactions__id__receipt_attachments__transaction_id',
      );

  $$ReceiptAttachmentsTableProcessedTableManager get receiptAttachmentsRefs {
    final manager = $$ReceiptAttachmentsTableTableManager(
      $_db,
      $_db.receiptAttachments,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receiptAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookkeepingTransactionsTableFilterComposer
    extends Composer<_$LedgerDatabase, $BookkeepingTransactionsTable> {
  $$BookkeepingTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> receiptAttachmentsRefs(
    Expression<bool> Function($$ReceiptAttachmentsTableFilterComposer f) f,
  ) {
    final $$ReceiptAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptAttachments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.receiptAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookkeepingTransactionsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $BookkeepingTransactionsTable> {
  $$BookkeepingTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookkeepingTransactionsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $BookkeepingTransactionsTable> {
  $$BookkeepingTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> receiptAttachmentsRefs<T extends Object>(
    Expression<T> Function($$ReceiptAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.receiptAttachments,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReceiptAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.receiptAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BookkeepingTransactionsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $BookkeepingTransactionsTable,
          BookkeepingTransaction,
          $$BookkeepingTransactionsTableFilterComposer,
          $$BookkeepingTransactionsTableOrderingComposer,
          $$BookkeepingTransactionsTableAnnotationComposer,
          $$BookkeepingTransactionsTableCreateCompanionBuilder,
          $$BookkeepingTransactionsTableUpdateCompanionBuilder,
          (BookkeepingTransaction, $$BookkeepingTransactionsTableReferences),
          BookkeepingTransaction,
          PrefetchHooks Function({
            bool profileId,
            bool accountId,
            bool categoryId,
            bool projectId,
            bool receiptAttachmentsRefs,
          })
        > {
  $$BookkeepingTransactionsTableTableManager(
    _$LedgerDatabase db,
    $BookkeepingTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookkeepingTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BookkeepingTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BookkeepingTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int?> deletedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookkeepingTransactionsCompanion(
                id: id,
                profileId: profileId,
                accountId: accountId,
                categoryId: categoryId,
                projectId: projectId,
                kind: kind,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                businessDate: businessDate,
                note: note,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String accountId,
                required String categoryId,
                Value<String?> projectId = const Value.absent(),
                required String kind,
                required int amountMinorUnits,
                required String currencyCode,
                required String businessDate,
                Value<String?> note = const Value.absent(),
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int?> deletedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookkeepingTransactionsCompanion.insert(
                id: id,
                profileId: profileId,
                accountId: accountId,
                categoryId: categoryId,
                projectId: projectId,
                kind: kind,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                businessDate: businessDate,
                note: note,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $BookkeepingTransactionsTable,
                    BookkeepingTransaction
                  >(table),
                  $$BookkeepingTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                accountId = false,
                categoryId = false,
                projectId = false,
                receiptAttachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receiptAttachmentsRefs) db.receiptAttachments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable:
                                $$BookkeepingTransactionsTableReferences
                                    ._profileIdTable(db),
                            referencedColumn:
                                $$BookkeepingTransactionsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable:
                                $$BookkeepingTransactionsTableReferences
                                    ._accountIdTable(db),
                            referencedColumn:
                                $$BookkeepingTransactionsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable:
                                $$BookkeepingTransactionsTableReferences
                                    ._categoryIdTable(db),
                            referencedColumn:
                                $$BookkeepingTransactionsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable:
                                $$BookkeepingTransactionsTableReferences
                                    ._projectIdTable(db),
                            referencedColumn:
                                $$BookkeepingTransactionsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptAttachmentsRefs)
                        await $_getPrefetchedData<
                          BookkeepingTransaction,
                          $BookkeepingTransactionsTable,
                          ReceiptAttachment
                        >(
                          currentTable: table,
                          referencedTable:
                              $$BookkeepingTransactionsTableReferences
                                  ._receiptAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BookkeepingTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BookkeepingTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $BookkeepingTransactionsTable,
      BookkeepingTransaction,
      $$BookkeepingTransactionsTableFilterComposer,
      $$BookkeepingTransactionsTableOrderingComposer,
      $$BookkeepingTransactionsTableAnnotationComposer,
      $$BookkeepingTransactionsTableCreateCompanionBuilder,
      $$BookkeepingTransactionsTableUpdateCompanionBuilder,
      (BookkeepingTransaction, $$BookkeepingTransactionsTableReferences),
      BookkeepingTransaction,
      PrefetchHooks Function({
        bool profileId,
        bool accountId,
        bool categoryId,
        bool projectId,
        bool receiptAttachmentsRefs,
      })
    >;
typedef $$TransfersTableCreateCompanionBuilder = TransfersCompanion Function({
  required String id,
  required String profileId,
  required String sourceAccountId,
  required String destinationAccountId,
  required int sourceMinorUnits,
  required String sourceCurrencyCode,
  required int destinationMinorUnits,
  required String destinationCurrencyCode,
  required String businessDate,
  Value<String?> note,
  required int createdAtUtc,
  required int updatedAtUtc,
  Value<int?> deletedAtUtc,
  Value<int> rowid,
});
typedef $$TransfersTableUpdateCompanionBuilder = TransfersCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> sourceAccountId,
  Value<String> destinationAccountId,
  Value<int> sourceMinorUnits,
  Value<String> sourceCurrencyCode,
  Value<int> destinationMinorUnits,
  Value<String> destinationCurrencyCode,
  Value<String> businessDate,
  Value<String?> note,
  Value<int> createdAtUtc,
  Value<int> updatedAtUtc,
  Value<int?> deletedAtUtc,
  Value<int> rowid,
});

final class $$TransfersTableReferences
    extends BaseReferences<_$LedgerDatabase, $TransfersTable, Transfer> {
  $$TransfersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) =>
      db.localProfiles.createAlias('transfers__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _sourceAccountIdTable(_$LedgerDatabase db) =>
      db.accounts.createAlias('transfers__source_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get sourceAccountId {
    final $_column = $_itemColumn<String>('source_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _destinationAccountIdTable(_$LedgerDatabase db) => db
      .accounts
      .createAlias('transfers__destination_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get destinationAccountId {
    final $_column = $_itemColumn<String>('destination_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _destinationAccountIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransfersTableFilterComposer
    extends Composer<_$LedgerDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceMinorUnits => $composableBuilder(
    column: $table.sourceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCurrencyCode => $composableBuilder(
    column: $table.sourceCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get destinationMinorUnits => $composableBuilder(
    column: $table.destinationMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationCurrencyCode => $composableBuilder(
    column: $table.destinationCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get sourceAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get destinationAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableOrderingComposer
    extends Composer<_$LedgerDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceMinorUnits => $composableBuilder(
    column: $table.sourceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCurrencyCode => $composableBuilder(
    column: $table.sourceCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get destinationMinorUnits => $composableBuilder(
    column: $table.destinationMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationCurrencyCode => $composableBuilder(
    column: $table.destinationCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get sourceAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get destinationAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceMinorUnits => $composableBuilder(
    column: $table.sourceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceCurrencyCode => $composableBuilder(
    column: $table.sourceCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get destinationMinorUnits => $composableBuilder(
    column: $table.destinationMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationCurrencyCode => $composableBuilder(
    column: $table.destinationCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get sourceAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get destinationAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $TransfersTable,
          Transfer,
          $$TransfersTableFilterComposer,
          $$TransfersTableOrderingComposer,
          $$TransfersTableAnnotationComposer,
          $$TransfersTableCreateCompanionBuilder,
          $$TransfersTableUpdateCompanionBuilder,
          (Transfer, $$TransfersTableReferences),
          Transfer,
          PrefetchHooks Function({
            bool profileId,
            bool sourceAccountId,
            bool destinationAccountId,
          })
        > {
  $$TransfersTableTableManager(_$LedgerDatabase db, $TransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> sourceAccountId = const Value.absent(),
                Value<String> destinationAccountId = const Value.absent(),
                Value<int> sourceMinorUnits = const Value.absent(),
                Value<String> sourceCurrencyCode = const Value.absent(),
                Value<int> destinationMinorUnits = const Value.absent(),
                Value<String> destinationCurrencyCode = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int?> deletedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion(
                id: id,
                profileId: profileId,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                sourceMinorUnits: sourceMinorUnits,
                sourceCurrencyCode: sourceCurrencyCode,
                destinationMinorUnits: destinationMinorUnits,
                destinationCurrencyCode: destinationCurrencyCode,
                businessDate: businessDate,
                note: note,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String sourceAccountId,
                required String destinationAccountId,
                required int sourceMinorUnits,
                required String sourceCurrencyCode,
                required int destinationMinorUnits,
                required String destinationCurrencyCode,
                required String businessDate,
                Value<String?> note = const Value.absent(),
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int?> deletedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion.insert(
                id: id,
                profileId: profileId,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                sourceMinorUnits: sourceMinorUnits,
                sourceCurrencyCode: sourceCurrencyCode,
                destinationMinorUnits: destinationMinorUnits,
                destinationCurrencyCode: destinationCurrencyCode,
                businessDate: businessDate,
                note: note,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransfersTable, Transfer>(table),
                  $$TransfersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                sourceAccountId = false,
                destinationAccountId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$TransfersTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$TransfersTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sourceAccountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceAccountId,
                            referencedTable: $$TransfersTableReferences
                                ._sourceAccountIdTable(db),
                            referencedColumn: $$TransfersTableReferences
                                ._sourceAccountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (destinationAccountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.destinationAccountId,
                            referencedTable: $$TransfersTableReferences
                                ._destinationAccountIdTable(db),
                            referencedColumn: $$TransfersTableReferences
                                ._destinationAccountIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $TransfersTable,
      Transfer,
      $$TransfersTableFilterComposer,
      $$TransfersTableOrderingComposer,
      $$TransfersTableAnnotationComposer,
      $$TransfersTableCreateCompanionBuilder,
      $$TransfersTableUpdateCompanionBuilder,
      (Transfer, $$TransfersTableReferences),
      Transfer,
      PrefetchHooks Function({
        bool profileId,
        bool sourceAccountId,
        bool destinationAccountId,
      })
    >;
typedef $$ReceiptAttachmentsTableCreateCompanionBuilder =
    ReceiptAttachmentsCompanion Function({
      required String id,
      required String profileId,
      required String transactionId,
      required String storageKey,
      required String mimeType,
      required int byteSize,
      required String sha256Hex,
      required int position,
      required int createdAtUtc,
      Value<int> rowid,
    });
typedef $$ReceiptAttachmentsTableUpdateCompanionBuilder =
    ReceiptAttachmentsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> transactionId,
      Value<String> storageKey,
      Value<String> mimeType,
      Value<int> byteSize,
      Value<String> sha256Hex,
      Value<int> position,
      Value<int> createdAtUtc,
      Value<int> rowid,
    });

final class $$ReceiptAttachmentsTableReferences
    extends
        BaseReferences<
          _$LedgerDatabase,
          $ReceiptAttachmentsTable,
          ReceiptAttachment
        > {
  $$ReceiptAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$LedgerDatabase db) => db
      .localProfiles
      .createAlias('receipt_attachments__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BookkeepingTransactionsTable _transactionIdTable(
    _$LedgerDatabase db,
  ) => db.bookkeepingTransactions.createAlias(
    'receipt_attachments__transaction_id__bookkeeping_transactions__id',
  );

  $$BookkeepingTransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$BookkeepingTransactionsTableTableManager(
      $_db,
      $_db.bookkeepingTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptAttachmentsTableFilterComposer
    extends Composer<_$LedgerDatabase, $ReceiptAttachmentsTable> {
  $$ReceiptAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BookkeepingTransactionsTableFilterComposer get transactionId {
    final $$BookkeepingTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReceiptAttachmentsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $ReceiptAttachmentsTable> {
  $$ReceiptAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BookkeepingTransactionsTableOrderingComposer get transactionId {
    final $$BookkeepingTransactionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableOrderingComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReceiptAttachmentsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $ReceiptAttachmentsTable> {
  $$ReceiptAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get sha256Hex =>
      $composableBuilder(column: $table.sha256Hex, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BookkeepingTransactionsTableAnnotationComposer get transactionId {
    final $$BookkeepingTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.bookkeepingTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookkeepingTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.bookkeepingTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReceiptAttachmentsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $ReceiptAttachmentsTable,
          ReceiptAttachment,
          $$ReceiptAttachmentsTableFilterComposer,
          $$ReceiptAttachmentsTableOrderingComposer,
          $$ReceiptAttachmentsTableAnnotationComposer,
          $$ReceiptAttachmentsTableCreateCompanionBuilder,
          $$ReceiptAttachmentsTableUpdateCompanionBuilder,
          (ReceiptAttachment, $$ReceiptAttachmentsTableReferences),
          ReceiptAttachment,
          PrefetchHooks Function({bool profileId, bool transactionId})
        > {
  $$ReceiptAttachmentsTableTableManager(
    _$LedgerDatabase db,
    $ReceiptAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> storageKey = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String> sha256Hex = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptAttachmentsCompanion(
                id: id,
                profileId: profileId,
                transactionId: transactionId,
                storageKey: storageKey,
                mimeType: mimeType,
                byteSize: byteSize,
                sha256Hex: sha256Hex,
                position: position,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String transactionId,
                required String storageKey,
                required String mimeType,
                required int byteSize,
                required String sha256Hex,
                required int position,
                required int createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ReceiptAttachmentsCompanion.insert(
                id: id,
                profileId: profileId,
                transactionId: transactionId,
                storageKey: storageKey,
                mimeType: mimeType,
                byteSize: byteSize,
                sha256Hex: sha256Hex,
                position: position,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceiptAttachmentsTable, ReceiptAttachment>(
                    table,
                  ),
                  $$ReceiptAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ReceiptAttachmentsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$ReceiptAttachmentsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (transactionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.transactionId,
                        referencedTable: $$ReceiptAttachmentsTableReferences
                            ._transactionIdTable(db),
                        referencedColumn: $$ReceiptAttachmentsTableReferences
                            ._transactionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $ReceiptAttachmentsTable,
      ReceiptAttachment,
      $$ReceiptAttachmentsTableFilterComposer,
      $$ReceiptAttachmentsTableOrderingComposer,
      $$ReceiptAttachmentsTableAnnotationComposer,
      $$ReceiptAttachmentsTableCreateCompanionBuilder,
      $$ReceiptAttachmentsTableUpdateCompanionBuilder,
      (ReceiptAttachment, $$ReceiptAttachmentsTableReferences),
      ReceiptAttachment,
      PrefetchHooks Function({bool profileId, bool transactionId})
    >;
typedef $$SyncLinkStatesTableCreateCompanionBuilder =
    SyncLinkStatesCompanion Function({
      Value<int> slot,
      Value<String?> cloudAccountId,
      Value<String> state,
      Value<bool> syncEnabled,
      Value<bool> needsReconciliation,
      required int updatedAtUtc,
    });
typedef $$SyncLinkStatesTableUpdateCompanionBuilder =
    SyncLinkStatesCompanion Function({
      Value<int> slot,
      Value<String?> cloudAccountId,
      Value<String> state,
      Value<bool> syncEnabled,
      Value<bool> needsReconciliation,
      Value<int> updatedAtUtc,
    });

class $$SyncLinkStatesTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncLinkStatesTable> {
  $$SyncLinkStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudAccountId => $composableBuilder(
    column: $table.cloudAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReconciliation => $composableBuilder(
    column: $table.needsReconciliation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLinkStatesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncLinkStatesTable> {
  $$SyncLinkStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudAccountId => $composableBuilder(
    column: $table.cloudAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReconciliation => $composableBuilder(
    column: $table.needsReconciliation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLinkStatesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncLinkStatesTable> {
  $$SyncLinkStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get cloudAccountId => $composableBuilder(
    column: $table.cloudAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsReconciliation => $composableBuilder(
    column: $table.needsReconciliation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$SyncLinkStatesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncLinkStatesTable,
          SyncLinkState,
          $$SyncLinkStatesTableFilterComposer,
          $$SyncLinkStatesTableOrderingComposer,
          $$SyncLinkStatesTableAnnotationComposer,
          $$SyncLinkStatesTableCreateCompanionBuilder,
          $$SyncLinkStatesTableUpdateCompanionBuilder,
          (
            SyncLinkState,
            BaseReferences<
              _$LedgerDatabase,
              $SyncLinkStatesTable,
              SyncLinkState
            >,
          ),
          SyncLinkState,
          PrefetchHooks Function()
        > {
  $$SyncLinkStatesTableTableManager(
    _$LedgerDatabase db,
    $SyncLinkStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLinkStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLinkStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLinkStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String?> cloudAccountId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<bool> needsReconciliation = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
              }) => SyncLinkStatesCompanion(
                slot: slot,
                cloudAccountId: cloudAccountId,
                state: state,
                syncEnabled: syncEnabled,
                needsReconciliation: needsReconciliation,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String?> cloudAccountId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<bool> needsReconciliation = const Value.absent(),
                required int updatedAtUtc,
              }) => SyncLinkStatesCompanion.insert(
                slot: slot,
                cloudAccountId: cloudAccountId,
                state: state,
                syncEnabled: syncEnabled,
                needsReconciliation: needsReconciliation,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncLinkStatesTable, SyncLinkState>(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncLinkStatesTable,
                    SyncLinkState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLinkStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncLinkStatesTable,
      SyncLinkState,
      $$SyncLinkStatesTableFilterComposer,
      $$SyncLinkStatesTableOrderingComposer,
      $$SyncLinkStatesTableAnnotationComposer,
      $$SyncLinkStatesTableCreateCompanionBuilder,
      $$SyncLinkStatesTableUpdateCompanionBuilder,
      (
        SyncLinkState,
        BaseReferences<_$LedgerDatabase, $SyncLinkStatesTable, SyncLinkState>,
      ),
      SyncLinkState,
      PrefetchHooks Function()
    >;
typedef $$SyncDeviceStatesTableCreateCompanionBuilder =
    SyncDeviceStatesCompanion Function({
      Value<int> slot,
      required String deviceId,
      required int createdAtUtc,
    });
typedef $$SyncDeviceStatesTableUpdateCompanionBuilder =
    SyncDeviceStatesCompanion Function({
      Value<int> slot,
      Value<String> deviceId,
      Value<int> createdAtUtc,
    });

class $$SyncDeviceStatesTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncDeviceStatesTable> {
  $$SyncDeviceStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncDeviceStatesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncDeviceStatesTable> {
  $$SyncDeviceStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncDeviceStatesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncDeviceStatesTable> {
  $$SyncDeviceStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$SyncDeviceStatesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncDeviceStatesTable,
          SyncDeviceState,
          $$SyncDeviceStatesTableFilterComposer,
          $$SyncDeviceStatesTableOrderingComposer,
          $$SyncDeviceStatesTableAnnotationComposer,
          $$SyncDeviceStatesTableCreateCompanionBuilder,
          $$SyncDeviceStatesTableUpdateCompanionBuilder,
          (
            SyncDeviceState,
            BaseReferences<
              _$LedgerDatabase,
              $SyncDeviceStatesTable,
              SyncDeviceState
            >,
          ),
          SyncDeviceState,
          PrefetchHooks Function()
        > {
  $$SyncDeviceStatesTableTableManager(
    _$LedgerDatabase db,
    $SyncDeviceStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDeviceStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDeviceStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDeviceStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
              }) => SyncDeviceStatesCompanion(
                slot: slot,
                deviceId: deviceId,
                createdAtUtc: createdAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                required String deviceId,
                required int createdAtUtc,
              }) => SyncDeviceStatesCompanion.insert(
                slot: slot,
                deviceId: deviceId,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncDeviceStatesTable, SyncDeviceState>(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncDeviceStatesTable,
                    SyncDeviceState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncDeviceStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncDeviceStatesTable,
      SyncDeviceState,
      $$SyncDeviceStatesTableFilterComposer,
      $$SyncDeviceStatesTableOrderingComposer,
      $$SyncDeviceStatesTableAnnotationComposer,
      $$SyncDeviceStatesTableCreateCompanionBuilder,
      $$SyncDeviceStatesTableUpdateCompanionBuilder,
      (
        SyncDeviceState,
        BaseReferences<
          _$LedgerDatabase,
          $SyncDeviceStatesTable,
          SyncDeviceState
        >,
      ),
      SyncDeviceState,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<int> slot,
      Value<int> lastAppliedSequence,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<int> slot,
      Value<int> lastAppliedSequence,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAppliedSequence => $composableBuilder(
    column: $table.lastAppliedSequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAppliedSequence => $composableBuilder(
    column: $table.lastAppliedSequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<int> get lastAppliedSequence => $composableBuilder(
    column: $table.lastAppliedSequence,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$LedgerDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$LedgerDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<int> lastAppliedSequence = const Value.absent(),
              }) => SyncCursorsCompanion(
                slot: slot,
                lastAppliedSequence: lastAppliedSequence,
              ),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<int> lastAppliedSequence = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                slot: slot,
                lastAppliedSequence: lastAppliedSequence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncCursorsTable,
                    SyncCursor
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$LedgerDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$SyncEntityStatesTableCreateCompanionBuilder =
    SyncEntityStatesCompanion Function({
      required String entityType,
      required String entityId,
      required int serverVersion,
      required int serverRevision,
      Value<int> rowid,
    });
typedef $$SyncEntityStatesTableUpdateCompanionBuilder =
    SyncEntityStatesCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<int> serverVersion,
      Value<int> serverRevision,
      Value<int> rowid,
    });

class $$SyncEntityStatesTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEntityStatesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEntityStatesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );
}

class $$SyncEntityStatesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncEntityStatesTable,
          SyncEntityState,
          $$SyncEntityStatesTableFilterComposer,
          $$SyncEntityStatesTableOrderingComposer,
          $$SyncEntityStatesTableAnnotationComposer,
          $$SyncEntityStatesTableCreateCompanionBuilder,
          $$SyncEntityStatesTableUpdateCompanionBuilder,
          (
            SyncEntityState,
            BaseReferences<
              _$LedgerDatabase,
              $SyncEntityStatesTable,
              SyncEntityState
            >,
          ),
          SyncEntityState,
          PrefetchHooks Function()
        > {
  $$SyncEntityStatesTableTableManager(
    _$LedgerDatabase db,
    $SyncEntityStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEntityStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEntityStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEntityStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<int> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStatesCompanion(
                entityType: entityType,
                entityId: entityId,
                serverVersion: serverVersion,
                serverRevision: serverRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required int serverVersion,
                required int serverRevision,
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStatesCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                serverVersion: serverVersion,
                serverRevision: serverRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncEntityStatesTable, SyncEntityState>(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncEntityStatesTable,
                    SyncEntityState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEntityStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncEntityStatesTable,
      SyncEntityState,
      $$SyncEntityStatesTableFilterComposer,
      $$SyncEntityStatesTableOrderingComposer,
      $$SyncEntityStatesTableAnnotationComposer,
      $$SyncEntityStatesTableCreateCompanionBuilder,
      $$SyncEntityStatesTableUpdateCompanionBuilder,
      (
        SyncEntityState,
        BaseReferences<
          _$LedgerDatabase,
          $SyncEntityStatesTable,
          SyncEntityState
        >,
      ),
      SyncEntityState,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> queueSequence,
  required String mutationId,
  required String entityType,
  required String entityId,
  required String operation,
  Value<int?> baseServerVersion,
  required String payloadJson,
  Value<String> state,
  Value<int> attemptCount,
  Value<int?> lastAttemptAtUtc,
  Value<int?> nextAttemptAtUtc,
  Value<String?> lastFailureCode,
  required int createdAtUtc,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> queueSequence,
  Value<String> mutationId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<int?> baseServerVersion,
  Value<String> payloadJson,
  Value<String> state,
  Value<int> attemptCount,
  Value<int?> lastAttemptAtUtc,
  Value<int?> nextAttemptAtUtc,
  Value<String?> lastFailureCode,
  Value<int> createdAtUtc,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get queueSequence => $composableBuilder(
    column: $table.queueSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAttemptAtUtc => $composableBuilder(
    column: $table.lastAttemptAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAtUtc => $composableBuilder(
    column: $table.nextAttemptAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastFailureCode => $composableBuilder(
    column: $table.lastFailureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get queueSequence => $composableBuilder(
    column: $table.queueSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAttemptAtUtc => $composableBuilder(
    column: $table.lastAttemptAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAtUtc => $composableBuilder(
    column: $table.nextAttemptAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastFailureCode => $composableBuilder(
    column: $table.lastFailureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get queueSequence => $composableBuilder(
    column: $table.queueSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAttemptAtUtc => $composableBuilder(
    column: $table.lastAttemptAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextAttemptAtUtc => $composableBuilder(
    column: $table.nextAttemptAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastFailureCode => $composableBuilder(
    column: $table.lastFailureCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$LedgerDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$LedgerDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> queueSequence = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int?> baseServerVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int?> lastAttemptAtUtc = const Value.absent(),
                Value<int?> nextAttemptAtUtc = const Value.absent(),
                Value<String?> lastFailureCode = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
              }) => SyncOutboxCompanion(
                queueSequence: queueSequence,
                mutationId: mutationId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                baseServerVersion: baseServerVersion,
                payloadJson: payloadJson,
                state: state,
                attemptCount: attemptCount,
                lastAttemptAtUtc: lastAttemptAtUtc,
                nextAttemptAtUtc: nextAttemptAtUtc,
                lastFailureCode: lastFailureCode,
                createdAtUtc: createdAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> queueSequence = const Value.absent(),
                required String mutationId,
                required String entityType,
                required String entityId,
                required String operation,
                Value<int?> baseServerVersion = const Value.absent(),
                required String payloadJson,
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int?> lastAttemptAtUtc = const Value.absent(),
                Value<int?> nextAttemptAtUtc = const Value.absent(),
                Value<String?> lastFailureCode = const Value.absent(),
                required int createdAtUtc,
              }) => SyncOutboxCompanion.insert(
                queueSequence: queueSequence,
                mutationId: mutationId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                baseServerVersion: baseServerVersion,
                payloadJson: payloadJson,
                state: state,
                attemptCount: attemptCount,
                lastAttemptAtUtc: lastAttemptAtUtc,
                nextAttemptAtUtc: nextAttemptAtUtc,
                lastFailureCode: lastFailureCode,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, SyncOutboxData>(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncOutboxTable,
                    SyncOutboxData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$LedgerDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      Value<String?> mutationId,
      required int baseServerVersion,
      required int remoteServerVersion,
      required int remoteServerRevision,
      required String localCandidateJson,
      required String remoteCandidateJson,
      required int detectedAtUtc,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String?> mutationId,
      Value<int> baseServerVersion,
      Value<int> remoteServerVersion,
      Value<int> remoteServerRevision,
      Value<String> localCandidateJson,
      Value<String> remoteCandidateJson,
      Value<int> detectedAtUtc,
      Value<String> status,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteServerVersion => $composableBuilder(
    column: $table.remoteServerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteServerRevision => $composableBuilder(
    column: $table.remoteServerRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localCandidateJson => $composableBuilder(
    column: $table.localCandidateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteCandidateJson => $composableBuilder(
    column: $table.remoteCandidateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteServerVersion => $composableBuilder(
    column: $table.remoteServerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteServerRevision => $composableBuilder(
    column: $table.remoteServerRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localCandidateJson => $composableBuilder(
    column: $table.localCandidateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteCandidateJson => $composableBuilder(
    column: $table.remoteCandidateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteServerVersion => $composableBuilder(
    column: $table.remoteServerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteServerRevision => $composableBuilder(
    column: $table.remoteServerRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localCandidateJson => $composableBuilder(
    column: $table.localCandidateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteCandidateJson => $composableBuilder(
    column: $table.remoteCandidateJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$LedgerDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(
    _$LedgerDatabase db,
    $SyncConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> mutationId = const Value.absent(),
                Value<int> baseServerVersion = const Value.absent(),
                Value<int> remoteServerVersion = const Value.absent(),
                Value<int> remoteServerRevision = const Value.absent(),
                Value<String> localCandidateJson = const Value.absent(),
                Value<String> remoteCandidateJson = const Value.absent(),
                Value<int> detectedAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                mutationId: mutationId,
                baseServerVersion: baseServerVersion,
                remoteServerVersion: remoteServerVersion,
                remoteServerRevision: remoteServerRevision,
                localCandidateJson: localCandidateJson,
                remoteCandidateJson: remoteCandidateJson,
                detectedAtUtc: detectedAtUtc,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                Value<String?> mutationId = const Value.absent(),
                required int baseServerVersion,
                required int remoteServerVersion,
                required int remoteServerRevision,
                required String localCandidateJson,
                required String remoteCandidateJson,
                required int detectedAtUtc,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                mutationId: mutationId,
                baseServerVersion: baseServerVersion,
                remoteServerVersion: remoteServerVersion,
                remoteServerRevision: remoteServerRevision,
                localCandidateJson: localCandidateJson,
                remoteCandidateJson: remoteCandidateJson,
                detectedAtUtc: detectedAtUtc,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, SyncConflict>(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncConflictsTable,
                    SyncConflict
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$LedgerDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$SyncReceiptSpoolEntriesTableCreateCompanionBuilder =
    SyncReceiptSpoolEntriesCompanion Function({
      required String attachmentId,
      required String storageKey,
      required String sha256Hex,
      required int byteSize,
      required int createdAtUtc,
      Value<int> rowid,
    });
typedef $$SyncReceiptSpoolEntriesTableUpdateCompanionBuilder =
    SyncReceiptSpoolEntriesCompanion Function({
      Value<String> attachmentId,
      Value<String> storageKey,
      Value<String> sha256Hex,
      Value<int> byteSize,
      Value<int> createdAtUtc,
      Value<int> rowid,
    });

class $$SyncReceiptSpoolEntriesTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncReceiptSpoolEntriesTable> {
  $$SyncReceiptSpoolEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncReceiptSpoolEntriesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncReceiptSpoolEntriesTable> {
  $$SyncReceiptSpoolEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncReceiptSpoolEntriesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncReceiptSpoolEntriesTable> {
  $$SyncReceiptSpoolEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256Hex =>
      $composableBuilder(column: $table.sha256Hex, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$SyncReceiptSpoolEntriesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncReceiptSpoolEntriesTable,
          SyncReceiptSpoolEntry,
          $$SyncReceiptSpoolEntriesTableFilterComposer,
          $$SyncReceiptSpoolEntriesTableOrderingComposer,
          $$SyncReceiptSpoolEntriesTableAnnotationComposer,
          $$SyncReceiptSpoolEntriesTableCreateCompanionBuilder,
          $$SyncReceiptSpoolEntriesTableUpdateCompanionBuilder,
          (
            SyncReceiptSpoolEntry,
            BaseReferences<
              _$LedgerDatabase,
              $SyncReceiptSpoolEntriesTable,
              SyncReceiptSpoolEntry
            >,
          ),
          SyncReceiptSpoolEntry,
          PrefetchHooks Function()
        > {
  $$SyncReceiptSpoolEntriesTableTableManager(
    _$LedgerDatabase db,
    $SyncReceiptSpoolEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncReceiptSpoolEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SyncReceiptSpoolEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncReceiptSpoolEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> attachmentId = const Value.absent(),
                Value<String> storageKey = const Value.absent(),
                Value<String> sha256Hex = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncReceiptSpoolEntriesCompanion(
                attachmentId: attachmentId,
                storageKey: storageKey,
                sha256Hex: sha256Hex,
                byteSize: byteSize,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attachmentId,
                required String storageKey,
                required String sha256Hex,
                required int byteSize,
                required int createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => SyncReceiptSpoolEntriesCompanion.insert(
                attachmentId: attachmentId,
                storageKey: storageKey,
                sha256Hex: sha256Hex,
                byteSize: byteSize,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $SyncReceiptSpoolEntriesTable,
                    SyncReceiptSpoolEntry
                  >(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncReceiptSpoolEntriesTable,
                    SyncReceiptSpoolEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncReceiptSpoolEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncReceiptSpoolEntriesTable,
      SyncReceiptSpoolEntry,
      $$SyncReceiptSpoolEntriesTableFilterComposer,
      $$SyncReceiptSpoolEntriesTableOrderingComposer,
      $$SyncReceiptSpoolEntriesTableAnnotationComposer,
      $$SyncReceiptSpoolEntriesTableCreateCompanionBuilder,
      $$SyncReceiptSpoolEntriesTableUpdateCompanionBuilder,
      (
        SyncReceiptSpoolEntry,
        BaseReferences<
          _$LedgerDatabase,
          $SyncReceiptSpoolEntriesTable,
          SyncReceiptSpoolEntry
        >,
      ),
      SyncReceiptSpoolEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncAttachmentCleanupTableCreateCompanionBuilder =
    SyncAttachmentCleanupCompanion Function({
      required String storagePath,
      Value<int> attemptCount,
      Value<int?> nextAttemptAtUtc,
      required int createdAtUtc,
      Value<int> rowid,
    });
typedef $$SyncAttachmentCleanupTableUpdateCompanionBuilder =
    SyncAttachmentCleanupCompanion Function({
      Value<String> storagePath,
      Value<int> attemptCount,
      Value<int?> nextAttemptAtUtc,
      Value<int> createdAtUtc,
      Value<int> rowid,
    });

class $$SyncAttachmentCleanupTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncAttachmentCleanupTable> {
  $$SyncAttachmentCleanupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAtUtc => $composableBuilder(
    column: $table.nextAttemptAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncAttachmentCleanupTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncAttachmentCleanupTable> {
  $$SyncAttachmentCleanupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAtUtc => $composableBuilder(
    column: $table.nextAttemptAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncAttachmentCleanupTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncAttachmentCleanupTable> {
  $$SyncAttachmentCleanupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextAttemptAtUtc => $composableBuilder(
    column: $table.nextAttemptAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$SyncAttachmentCleanupTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncAttachmentCleanupTable,
          SyncAttachmentCleanupData,
          $$SyncAttachmentCleanupTableFilterComposer,
          $$SyncAttachmentCleanupTableOrderingComposer,
          $$SyncAttachmentCleanupTableAnnotationComposer,
          $$SyncAttachmentCleanupTableCreateCompanionBuilder,
          $$SyncAttachmentCleanupTableUpdateCompanionBuilder,
          (
            SyncAttachmentCleanupData,
            BaseReferences<
              _$LedgerDatabase,
              $SyncAttachmentCleanupTable,
              SyncAttachmentCleanupData
            >,
          ),
          SyncAttachmentCleanupData,
          PrefetchHooks Function()
        > {
  $$SyncAttachmentCleanupTableTableManager(
    _$LedgerDatabase db,
    $SyncAttachmentCleanupTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncAttachmentCleanupTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SyncAttachmentCleanupTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncAttachmentCleanupTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> storagePath = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAtUtc = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncAttachmentCleanupCompanion(
                storagePath: storagePath,
                attemptCount: attemptCount,
                nextAttemptAtUtc: nextAttemptAtUtc,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storagePath,
                Value<int> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAtUtc = const Value.absent(),
                required int createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => SyncAttachmentCleanupCompanion.insert(
                storagePath: storagePath,
                attemptCount: attemptCount,
                nextAttemptAtUtc: nextAttemptAtUtc,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $SyncAttachmentCleanupTable,
                    SyncAttachmentCleanupData
                  >(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncAttachmentCleanupTable,
                    SyncAttachmentCleanupData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncAttachmentCleanupTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncAttachmentCleanupTable,
      SyncAttachmentCleanupData,
      $$SyncAttachmentCleanupTableFilterComposer,
      $$SyncAttachmentCleanupTableOrderingComposer,
      $$SyncAttachmentCleanupTableAnnotationComposer,
      $$SyncAttachmentCleanupTableCreateCompanionBuilder,
      $$SyncAttachmentCleanupTableUpdateCompanionBuilder,
      (
        SyncAttachmentCleanupData,
        BaseReferences<
          _$LedgerDatabase,
          $SyncAttachmentCleanupTable,
          SyncAttachmentCleanupData
        >,
      ),
      SyncAttachmentCleanupData,
      PrefetchHooks Function()
    >;
typedef $$SyncOnboardingStatesTableCreateCompanionBuilder =
    SyncOnboardingStatesCompanion Function({
      Value<int> slot,
      Value<String?> datasetGeneration,
      Value<String> stage,
      Value<String?> initializationOperationId,
      Value<bool> paused,
      Value<int?> lastSuccessfulSyncAtUtc,
      required int updatedAtUtc,
    });
typedef $$SyncOnboardingStatesTableUpdateCompanionBuilder =
    SyncOnboardingStatesCompanion Function({
      Value<int> slot,
      Value<String?> datasetGeneration,
      Value<String> stage,
      Value<String?> initializationOperationId,
      Value<bool> paused,
      Value<int?> lastSuccessfulSyncAtUtc,
      Value<int> updatedAtUtc,
    });

class $$SyncOnboardingStatesTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncOnboardingStatesTable> {
  $$SyncOnboardingStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetGeneration => $composableBuilder(
    column: $table.datasetGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initializationOperationId => $composableBuilder(
    column: $table.initializationOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSuccessfulSyncAtUtc => $composableBuilder(
    column: $table.lastSuccessfulSyncAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOnboardingStatesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncOnboardingStatesTable> {
  $$SyncOnboardingStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetGeneration => $composableBuilder(
    column: $table.datasetGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initializationOperationId => $composableBuilder(
    column: $table.initializationOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSuccessfulSyncAtUtc => $composableBuilder(
    column: $table.lastSuccessfulSyncAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOnboardingStatesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncOnboardingStatesTable> {
  $$SyncOnboardingStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get datasetGeneration => $composableBuilder(
    column: $table.datasetGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get initializationOperationId => $composableBuilder(
    column: $table.initializationOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  GeneratedColumn<int> get lastSuccessfulSyncAtUtc => $composableBuilder(
    column: $table.lastSuccessfulSyncAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$SyncOnboardingStatesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncOnboardingStatesTable,
          SyncOnboardingState,
          $$SyncOnboardingStatesTableFilterComposer,
          $$SyncOnboardingStatesTableOrderingComposer,
          $$SyncOnboardingStatesTableAnnotationComposer,
          $$SyncOnboardingStatesTableCreateCompanionBuilder,
          $$SyncOnboardingStatesTableUpdateCompanionBuilder,
          (
            SyncOnboardingState,
            BaseReferences<
              _$LedgerDatabase,
              $SyncOnboardingStatesTable,
              SyncOnboardingState
            >,
          ),
          SyncOnboardingState,
          PrefetchHooks Function()
        > {
  $$SyncOnboardingStatesTableTableManager(
    _$LedgerDatabase db,
    $SyncOnboardingStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOnboardingStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOnboardingStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncOnboardingStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String?> datasetGeneration = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String?> initializationOperationId = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int?> lastSuccessfulSyncAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
              }) => SyncOnboardingStatesCompanion(
                slot: slot,
                datasetGeneration: datasetGeneration,
                stage: stage,
                initializationOperationId: initializationOperationId,
                paused: paused,
                lastSuccessfulSyncAtUtc: lastSuccessfulSyncAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String?> datasetGeneration = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String?> initializationOperationId = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int?> lastSuccessfulSyncAtUtc = const Value.absent(),
                required int updatedAtUtc,
              }) => SyncOnboardingStatesCompanion.insert(
                slot: slot,
                datasetGeneration: datasetGeneration,
                stage: stage,
                initializationOperationId: initializationOperationId,
                paused: paused,
                lastSuccessfulSyncAtUtc: lastSuccessfulSyncAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOnboardingStatesTable, SyncOnboardingState>(
                    table,
                  ),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncOnboardingStatesTable,
                    SyncOnboardingState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOnboardingStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncOnboardingStatesTable,
      SyncOnboardingState,
      $$SyncOnboardingStatesTableFilterComposer,
      $$SyncOnboardingStatesTableOrderingComposer,
      $$SyncOnboardingStatesTableAnnotationComposer,
      $$SyncOnboardingStatesTableCreateCompanionBuilder,
      $$SyncOnboardingStatesTableUpdateCompanionBuilder,
      (
        SyncOnboardingState,
        BaseReferences<
          _$LedgerDatabase,
          $SyncOnboardingStatesTable,
          SyncOnboardingState
        >,
      ),
      SyncOnboardingState,
      PrefetchHooks Function()
    >;
typedef $$SyncInitializationEntitiesTableCreateCompanionBuilder =
    SyncInitializationEntitiesCompanion Function({
      Value<int> ordinal,
      required String entityType,
      required String entityId,
      required String payloadJson,
    });
typedef $$SyncInitializationEntitiesTableUpdateCompanionBuilder =
    SyncInitializationEntitiesCompanion Function({
      Value<int> ordinal,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> payloadJson,
    });

class $$SyncInitializationEntitiesTableFilterComposer
    extends Composer<_$LedgerDatabase, $SyncInitializationEntitiesTable> {
  $$SyncInitializationEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncInitializationEntitiesTableOrderingComposer
    extends Composer<_$LedgerDatabase, $SyncInitializationEntitiesTable> {
  $$SyncInitializationEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncInitializationEntitiesTableAnnotationComposer
    extends Composer<_$LedgerDatabase, $SyncInitializationEntitiesTable> {
  $$SyncInitializationEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$SyncInitializationEntitiesTableTableManager
    extends
        RootTableManager<
          _$LedgerDatabase,
          $SyncInitializationEntitiesTable,
          SyncInitializationEntity,
          $$SyncInitializationEntitiesTableFilterComposer,
          $$SyncInitializationEntitiesTableOrderingComposer,
          $$SyncInitializationEntitiesTableAnnotationComposer,
          $$SyncInitializationEntitiesTableCreateCompanionBuilder,
          $$SyncInitializationEntitiesTableUpdateCompanionBuilder,
          (
            SyncInitializationEntity,
            BaseReferences<
              _$LedgerDatabase,
              $SyncInitializationEntitiesTable,
              SyncInitializationEntity
            >,
          ),
          SyncInitializationEntity,
          PrefetchHooks Function()
        > {
  $$SyncInitializationEntitiesTableTableManager(
    _$LedgerDatabase db,
    $SyncInitializationEntitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncInitializationEntitiesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SyncInitializationEntitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncInitializationEntitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> ordinal = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
              }) => SyncInitializationEntitiesCompanion(
                ordinal: ordinal,
                entityType: entityType,
                entityId: entityId,
                payloadJson: payloadJson,
              ),
          createCompanionCallback:
              ({
                Value<int> ordinal = const Value.absent(),
                required String entityType,
                required String entityId,
                required String payloadJson,
              }) => SyncInitializationEntitiesCompanion.insert(
                ordinal: ordinal,
                entityType: entityType,
                entityId: entityId,
                payloadJson: payloadJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $SyncInitializationEntitiesTable,
                    SyncInitializationEntity
                  >(table),
                  BaseReferences<
                    _$LedgerDatabase,
                    $SyncInitializationEntitiesTable,
                    SyncInitializationEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncInitializationEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$LedgerDatabase,
      $SyncInitializationEntitiesTable,
      SyncInitializationEntity,
      $$SyncInitializationEntitiesTableFilterComposer,
      $$SyncInitializationEntitiesTableOrderingComposer,
      $$SyncInitializationEntitiesTableAnnotationComposer,
      $$SyncInitializationEntitiesTableCreateCompanionBuilder,
      $$SyncInitializationEntitiesTableUpdateCompanionBuilder,
      (
        SyncInitializationEntity,
        BaseReferences<
          _$LedgerDatabase,
          $SyncInitializationEntitiesTable,
          SyncInitializationEntity
        >,
      ),
      SyncInitializationEntity,
      PrefetchHooks Function()
    >;

class $LedgerDatabaseManager {
  final _$LedgerDatabase _db;
  $LedgerDatabaseManager(this._db);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$BookkeepingTransactionsTableTableManager get bookkeepingTransactions =>
      $$BookkeepingTransactionsTableTableManager(
        _db,
        _db.bookkeepingTransactions,
      );
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
  $$ReceiptAttachmentsTableTableManager get receiptAttachments =>
      $$ReceiptAttachmentsTableTableManager(_db, _db.receiptAttachments);
  $$SyncLinkStatesTableTableManager get syncLinkStates =>
      $$SyncLinkStatesTableTableManager(_db, _db.syncLinkStates);
  $$SyncDeviceStatesTableTableManager get syncDeviceStates =>
      $$SyncDeviceStatesTableTableManager(_db, _db.syncDeviceStates);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncEntityStatesTableTableManager get syncEntityStates =>
      $$SyncEntityStatesTableTableManager(_db, _db.syncEntityStates);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncReceiptSpoolEntriesTableTableManager get syncReceiptSpoolEntries =>
      $$SyncReceiptSpoolEntriesTableTableManager(
        _db,
        _db.syncReceiptSpoolEntries,
      );
  $$SyncAttachmentCleanupTableTableManager get syncAttachmentCleanup =>
      $$SyncAttachmentCleanupTableTableManager(_db, _db.syncAttachmentCleanup);
  $$SyncOnboardingStatesTableTableManager get syncOnboardingStates =>
      $$SyncOnboardingStatesTableTableManager(_db, _db.syncOnboardingStates);
  $$SyncInitializationEntitiesTableTableManager
  get syncInitializationEntities =>
      $$SyncInitializationEntitiesTableTableManager(
        _db,
        _db.syncInitializationEntities,
      );
}
