//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct TSThreadRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    public static let databaseTableName: String = TSThreadSerializer.table.tableName

    public let id: UInt64

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let archivalDate: Date?
    public let archivedAsOfMessageSortId: Bool?
    public let conversationColorName: String
    public let creationDate: Date
    public let isArchivedByLegacyTimestampForSorting: Bool
    public let lastMessageDate: Date?
    public let messageDraft: String?
    public let mutedUntilDate: Date?
    public let shouldThreadBeVisible: Bool

    // Subclass properties
    public let groupModel: Data?
    public let hasDismissedOffers: Bool?

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case archivalDate
        case archivedAsOfMessageSortId
        case conversationColorName
        case creationDate
        case isArchivedByLegacyTimestampForSorting
        case lastMessageDate
        case messageDraft
        case mutedUntilDate
        case shouldThreadBeVisible
        case groupModel
        case hasDismissedOffers
    }

    public static func columnName(_ column: TSThreadRecord.CodingKeys) -> String {
        return column.rawValue
    }

}

// MARK: - SDSSerializable

extension TSThread: SDSSerializable {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        case let model as TSGroupThread:
            assert(type(of: model) == TSGroupThread.self)
            return TSGroupThreadSerializer(model: model)
        case let model as TSContactThread:
            assert(type(of: model) == TSContactThread.self)
            return TSContactThreadSerializer(model: model)
        default:
            return TSThreadSerializer(model: self)
        }
    }
}

// MARK: - Table Metadata

extension TSThreadSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int, columnIndex: 0)
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let archivalDateColumn = SDSColumnMetadata(columnName: "archivalDate", columnType: .int64, isOptional: true, columnIndex: 3)
    static let archivedAsOfMessageSortIdColumn = SDSColumnMetadata(columnName: "archivedAsOfMessageSortId", columnType: .int, isOptional: true, columnIndex: 4)
    static let conversationColorNameColumn = SDSColumnMetadata(columnName: "conversationColorName", columnType: .unicodeString, columnIndex: 5)
    static let creationDateColumn = SDSColumnMetadata(columnName: "creationDate", columnType: .int64, columnIndex: 6)
    static let isArchivedByLegacyTimestampForSortingColumn = SDSColumnMetadata(columnName: "isArchivedByLegacyTimestampForSorting", columnType: .int, columnIndex: 7)
    static let lastMessageDateColumn = SDSColumnMetadata(columnName: "lastMessageDate", columnType: .int64, isOptional: true, columnIndex: 8)
    static let messageDraftColumn = SDSColumnMetadata(columnName: "messageDraft", columnType: .unicodeString, isOptional: true, columnIndex: 9)
    static let mutedUntilDateColumn = SDSColumnMetadata(columnName: "mutedUntilDate", columnType: .int64, isOptional: true, columnIndex: 10)
    static let shouldThreadBeVisibleColumn = SDSColumnMetadata(columnName: "shouldThreadBeVisible", columnType: .int, columnIndex: 11)
    // Subclass properties
    static let groupModelColumn = SDSColumnMetadata(columnName: "groupModel", columnType: .blob, isOptional: true, columnIndex: 12)
    static let hasDismissedOffersColumn = SDSColumnMetadata(columnName: "hasDismissedOffers", columnType: .int, isOptional: true, columnIndex: 13)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(tableName: "model_TSThread", columns: [
        recordTypeColumn,
        idColumn,
        uniqueIdColumn,
        archivalDateColumn,
        archivedAsOfMessageSortIdColumn,
        conversationColorNameColumn,
        creationDateColumn,
        isArchivedByLegacyTimestampForSortingColumn,
        lastMessageDateColumn,
        messageDraftColumn,
        mutedUntilDateColumn,
        shouldThreadBeVisibleColumn,
        groupModelColumn,
        hasDismissedOffersColumn
        ])

}

// MARK: - Deserialization

extension TSThreadSerializer {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func sdsDeserialize(statement: SelectStatement) throws -> TSThread {

        if OWSIsDebugBuild() {
            guard statement.columnNames == table.selectColumnNames else {
                owsFailDebug("Unexpected columns: \(statement.columnNames) != \(table.selectColumnNames)")
                throw SDSError.invalidResult
            }
        }

        // SDSDeserializer is used to convert column values into Swift values.
        let deserializer = SDSDeserializer(sqliteStatement: statement.sqliteStatement)
        let recordTypeValue = try deserializer.int(at: 0)
        guard let recordType = SDSRecordType(rawValue: UInt(recordTypeValue)) else {
            owsFailDebug("Invalid recordType: \(recordTypeValue)")
            throw SDSError.invalidResult
        }
        switch recordType {
        case .contactThread:

            let uniqueId = try deserializer.string(at: uniqueIdColumn.columnIndex)
            let archivalDate = try deserializer.optionalDate(at: archivalDateColumn.columnIndex)
            let archivedAsOfMessageSortId = try deserializer.optionalBoolAsNSNumber(at: archivedAsOfMessageSortIdColumn.columnIndex)
            let conversationColorName = ConversationColorName(rawValue: try deserializer.string(at: conversationColorNameColumn.columnIndex))
            let creationDate = try deserializer.date(at: creationDateColumn.columnIndex)
            let isArchivedByLegacyTimestampForSorting = try deserializer.bool(at: isArchivedByLegacyTimestampForSortingColumn.columnIndex)
            let lastMessageDate = try deserializer.optionalDate(at: lastMessageDateColumn.columnIndex)
            let messageDraft = try deserializer.optionalString(at: messageDraftColumn.columnIndex)
            let mutedUntilDate = try deserializer.optionalDate(at: mutedUntilDateColumn.columnIndex)
            let shouldThreadBeVisible = try deserializer.bool(at: shouldThreadBeVisibleColumn.columnIndex)
            let hasDismissedOffers = try deserializer.bool(at: hasDismissedOffersColumn.columnIndex)

            return TSContactThread(uniqueId: uniqueId,
                                   archivalDate: archivalDate,
                                   archivedAsOfMessageSortId: archivedAsOfMessageSortId,
                                   conversationColorName: conversationColorName,
                                   creationDate: creationDate,
                                   isArchivedByLegacyTimestampForSorting: isArchivedByLegacyTimestampForSorting,
                                   lastMessageDate: lastMessageDate,
                                   messageDraft: messageDraft,
                                   mutedUntilDate: mutedUntilDate,
                                   shouldThreadBeVisible: shouldThreadBeVisible,
                                   hasDismissedOffers: hasDismissedOffers)

        case .groupThread:

            let uniqueId = try deserializer.string(at: uniqueIdColumn.columnIndex)
            let archivalDate = try deserializer.optionalDate(at: archivalDateColumn.columnIndex)
            let archivedAsOfMessageSortId = try deserializer.optionalBoolAsNSNumber(at: archivedAsOfMessageSortIdColumn.columnIndex)
            let conversationColorName = ConversationColorName(rawValue: try deserializer.string(at: conversationColorNameColumn.columnIndex))
            let creationDate = try deserializer.date(at: creationDateColumn.columnIndex)
            let isArchivedByLegacyTimestampForSorting = try deserializer.bool(at: isArchivedByLegacyTimestampForSortingColumn.columnIndex)
            let lastMessageDate = try deserializer.optionalDate(at: lastMessageDateColumn.columnIndex)
            let messageDraft = try deserializer.optionalString(at: messageDraftColumn.columnIndex)
            let mutedUntilDate = try deserializer.optionalDate(at: mutedUntilDateColumn.columnIndex)
            let shouldThreadBeVisible = try deserializer.bool(at: shouldThreadBeVisibleColumn.columnIndex)
            let groupModelSerialized: Data = try deserializer.blob(at: groupModelColumn.columnIndex)
            let groupModel: TSGroupModel = try SDSDeserializer.unarchive(groupModelSerialized)

            return TSGroupThread(uniqueId: uniqueId,
                                 archivalDate: archivalDate,
                                 archivedAsOfMessageSortId: archivedAsOfMessageSortId,
                                 conversationColorName: conversationColorName,
                                 creationDate: creationDate,
                                 isArchivedByLegacyTimestampForSorting: isArchivedByLegacyTimestampForSorting,
                                 lastMessageDate: lastMessageDate,
                                 messageDraft: messageDraft,
                                 mutedUntilDate: mutedUntilDate,
                                 shouldThreadBeVisible: shouldThreadBeVisible,
                                 groupModel: groupModel)

        case .thread:

            let uniqueId = try deserializer.string(at: uniqueIdColumn.columnIndex)
            let archivalDate = try deserializer.optionalDate(at: archivalDateColumn.columnIndex)
            let archivedAsOfMessageSortId = try deserializer.optionalBoolAsNSNumber(at: archivedAsOfMessageSortIdColumn.columnIndex)
            let conversationColorName = ConversationColorName(rawValue: try deserializer.string(at: conversationColorNameColumn.columnIndex))
            let creationDate = try deserializer.date(at: creationDateColumn.columnIndex)
            let isArchivedByLegacyTimestampForSorting = try deserializer.bool(at: isArchivedByLegacyTimestampForSortingColumn.columnIndex)
            let lastMessageDate = try deserializer.optionalDate(at: lastMessageDateColumn.columnIndex)
            let messageDraft = try deserializer.optionalString(at: messageDraftColumn.columnIndex)
            let mutedUntilDate = try deserializer.optionalDate(at: mutedUntilDateColumn.columnIndex)
            let shouldThreadBeVisible = try deserializer.bool(at: shouldThreadBeVisibleColumn.columnIndex)

            return TSThread(uniqueId: uniqueId,
                            archivalDate: archivalDate,
                            archivedAsOfMessageSortId: archivedAsOfMessageSortId,
                            conversationColorName: conversationColorName,
                            creationDate: creationDate,
                            isArchivedByLegacyTimestampForSorting: isArchivedByLegacyTimestampForSorting,
                            lastMessageDate: lastMessageDate,
                            messageDraft: messageDraft,
                            mutedUntilDate: mutedUntilDate,
                            shouldThreadBeVisible: shouldThreadBeVisible)

        default:
            owsFail("Invalid record type \(recordType)")
        }
    }
}

// MARK: - Save/Remove/Update

@objc
extension TSThread {
    public func anySave(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            save(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            SDSSerialization.save(entity: self, transaction: grdbTransaction)
        }
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    public func anyUpdateWith(transaction: SDSAnyWriteTransaction, block: (TSThread) -> Void) {
        guard let uniqueId = uniqueId else {
            owsFailDebug("Missing uniqueId.")
            return
        }

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        block(self)
        block(dbCopy)

        dbCopy.anySave(transaction: transaction)
    }

    public func anyRemove(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            remove(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            SDSSerialization.delete(entity: self, transaction: grdbTransaction)
        }
    }
}

// MARK: - TSThreadCursor

@objc
public class TSThreadCursor: NSObject {
    private let cursor: SDSCursor<TSThread>

    init(cursor: SDSCursor<TSThread>) {
        self.cursor = cursor
    }

    // TODO: Revisit error handling in this class.
    public func next() throws -> TSThread? {
        return try cursor.next()
    }

    public func all() throws -> [TSThread] {
        return try cursor.all()
    }
}

// MARK: - Obj-C Fetch

// TODO: We may eventually want to define some combination of:
//
// * fetchCursor, fetchOne, fetchAll, etc. (ala GRDB)
// * Optional "where clause" parameters for filtering.
// * Async flavors with completions.
//
// TODO: I've defined flavors that take a read transaction.
//       Or we might take a "connection" if we end up having that class.
@objc
extension TSThread {
    public class func grdbFetchCursor(transaction: GRDBReadTransaction) -> TSThreadCursor {
        return TSThreadCursor(cursor: SDSSerialization.fetchCursor(tableMetadata: TSThreadSerializer.table,
                                                                   transaction: transaction,
                                                                   deserialize: TSThreadSerializer.sdsDeserialize))
    }

    // Fetches a single model by "unique id".
    public class func anyFetch(uniqueId: String,
                               transaction: SDSAnyReadTransaction) -> TSThread? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return TSThread.fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let tableMetadata = TSThreadSerializer.table
            let columnNames: [String] = tableMetadata.selectColumnNames
            let columnsSQL: String = columnNames.map { $0.quotedDatabaseIdentifier }.joined(separator: ", ")
            let tableName: String = tableMetadata.tableName
            let uniqueIdColumnName: String = TSThreadSerializer.uniqueIdColumn.columnName
            let sql: String = "SELECT \(columnsSQL) FROM \(tableName.quotedDatabaseIdentifier) WHERE \(uniqueIdColumnName.quotedDatabaseIdentifier) == ?"

            let cursor = TSThread.grdbFetchCursor(sql: sql,
                                                  arguments: [uniqueId],
                                                  transaction: grdbTransaction)
            do {
                return try cursor.next()
            } catch {
                owsFailDebug("error: \(error)")
                return nil
            }
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    // Traversal aborts if the visitor returns false.
    public class func anyVisitAll(transaction: SDSAnyReadTransaction, visitor: @escaping (TSThread) -> Bool) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            TSThread.enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? TSThread else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                guard visitor(value) else {
                    stop.pointee = true
                    return
                }
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = TSThread.grdbFetchCursor(transaction: grdbTransaction)
                while let value = try cursor.next() {
                    guard visitor(value) else {
                        return
                    }
                }
            } catch let error as NSError {
                owsFailDebug("Couldn't fetch models: \(error)")
            }
        }
    }

    // Does not order the results.
    public class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [TSThread] {
        var result = [TSThread]()
        anyVisitAll(transaction: transaction) { (model) in
            result.append(model)
            return true
        }
        return result
    }
}

// MARK: - Swift Fetch

extension TSThread {
    public class func grdbFetchCursor(sql: String,
                                      arguments: [DatabaseValueConvertible]?,
                                      transaction: GRDBReadTransaction) -> TSThreadCursor {
        var statementArguments: StatementArguments?
        if let arguments = arguments {
            guard let statementArgs = StatementArguments(arguments) else {
                owsFail("Could not convert arguments.")
            }
            statementArguments = statementArgs
        }
        return TSThreadCursor(cursor: SDSSerialization.fetchCursor(sql: sql,
                                                             arguments: statementArguments,
                                                             transaction: transaction,
                                                                   deserialize: TSThreadSerializer.sdsDeserialize))
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class TSThreadSerializer: SDSSerializer {

    private let model: TSThread
    public required init(model: TSThread) {
        self.model = model
    }

    public func serializableColumnTableMetadata() -> SDSTableMetadata {
        return TSThreadSerializer.table
    }

    public func insertColumnNames() -> [String] {
        // When we insert a new row, we include the following columns:
        //
        // * "record type"
        // * "unique id"
        // * ...all columns that we set when updating.
        return [
            TSThreadSerializer.recordTypeColumn.columnName,
            uniqueIdColumnName()
            ] + updateColumnNames()

    }

    public func insertColumnValues() -> [DatabaseValueConvertible] {
        let result: [DatabaseValueConvertible] = [
            SDSRecordType.thread.rawValue
            ] + [uniqueIdColumnValue()] + updateColumnValues()
        if OWSIsDebugBuild() {
            if result.count != insertColumnNames().count {
                owsFailDebug("Update mismatch: \(result.count) != \(insertColumnNames().count)")
            }
        }
        return result
    }

    public func updateColumnNames() -> [String] {
        return [
            TSThreadSerializer.archivalDateColumn,
            TSThreadSerializer.archivedAsOfMessageSortIdColumn,
            TSThreadSerializer.conversationColorNameColumn,
            TSThreadSerializer.creationDateColumn,
            TSThreadSerializer.isArchivedByLegacyTimestampForSortingColumn,
            TSThreadSerializer.lastMessageDateColumn,
            TSThreadSerializer.messageDraftColumn,
            TSThreadSerializer.mutedUntilDateColumn,
            TSThreadSerializer.shouldThreadBeVisibleColumn
            ].map { $0.columnName }
    }

    public func updateColumnValues() -> [DatabaseValueConvertible] {
        let result: [DatabaseValueConvertible] = [
            self.model.archivalDate ?? DatabaseValue.null,
            self.model.archivedAsOfMessageSortId ?? DatabaseValue.null,
            self.model.conversationColorName.rawValue,
            self.model.creationDate,
            self.model.isArchivedByLegacyTimestampForSorting,
            self.model.lastMessageDate ?? DatabaseValue.null,
            self.model.messageDraft ?? DatabaseValue.null,
            self.model.mutedUntilDate ?? DatabaseValue.null,
            self.model.shouldThreadBeVisible

        ]
        if OWSIsDebugBuild() {
            if result.count != updateColumnNames().count {
                owsFailDebug("Update mismatch: \(result.count) != \(updateColumnNames().count)")
            }
        }
        return result
    }

    public func uniqueIdColumnName() -> String {
        return TSThreadSerializer.uniqueIdColumn.columnName
    }

    // TODO: uniqueId is currently an optional on our models.
    //       We should probably make the return type here String?
    public func uniqueIdColumnValue() -> DatabaseValueConvertible {
        // FIXME remove force unwrap
        return model.uniqueId!
    }
}
