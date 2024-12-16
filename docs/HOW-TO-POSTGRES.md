
# Brief instructions on how to work with PostgreSQL (Debezium case)

## Calculate the size of the WAL

### PostgreSQL 13+

```sql
SELECT ( SUM(size) / 1024 / 1024 ) AS "WAL_Space_Used_MB" FROM pg_ls_waldir();
```

### PostgreSQL 11 (deprecated)

```sql
SELECT ( a.wals::bigint * b.wal_seg_size::bigint / 1024 / 1024 ) AS "WAL_Space_Used_MB"
FROM   (
          SELECT count(*) wals
          FROM   pg_ls_dir('pg_wal')
          WHERE  pg_ls_dir ~ '^[0-9A-F]{24}'
       ) a,
       (
          SELECT  setting wal_seg_size
          FROM    pg_settings
          WHERE   name = 'wal_segment_size'
       ) b;
```

## Find out a lag of slots and status

```sql
SELECT slot_name, database, active, wal_status,
  pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) as replicationSlotLag,
  pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn)) as confirmedLag
FROM pg_catalog.pg_replication_slots;
```

## Find out details of slot/replication status

```sql
SELECT * FROM pg_replication_slots;
SELECT * FROM pg_stat_replication;
```

## Remove slot

```sql
SELECT pg_drop_replication_slot ('<SLOT_NAME>');
```

## Find out details of publication

```sql
SELECT * FROM pg_publication;
SELECT * FROM pg_publication_tables;
```

## Remove publication

```sql
DROP PUBLICATION <PUBLICATION_NAME>;
```

## Remove a table from publication

```sql
ALTER PUBLICATION <PUBLICATION_NAME> DROP TABLE <TABLE_NAME>;
```

## Add a table to publication

```sql
ALTER PUBLICATION <PUBLICATION_NAME> ADD TABLE <TABLE_NAME>;
```

## Change "REPLICA IDENTITY" for table

```sql
ALTER TABLE <TABLE_NAME> REPLICA IDENTITY FULL;
```

## Check "REPLICA IDENTITY" status

```sql
SELECT relname, 
       CASE relreplident
            WHEN 'd' THEN 'DEFAULT'
            WHEN 'n' THEN 'NOTHING'
            WHEN 'f' THEN 'FULL'
            WHEN 'i' THEN 'INDEX'
       END AS replica_identity
FROM pg_class
WHERE relname = '<TABLE_NAME>';
```
