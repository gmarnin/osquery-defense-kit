-- Find unexpected executables in /dev
--
-- references:
--   * https://www.sandflysecurity.com/blog/bpfdoor-an-evasive-linux-backdoor-technical-analysis/
--
-- tags: persistent state filesystem
SELECT
  file.path,
  file.directory,
  uid,
  gid,
  mode,
  file.mtime,
  file.size,
  hash.sha256,
  magic.data
FROM
  file
  LEFT JOIN hash on file.path = hash.path
  LEFT JOIN magic ON file.path = magic.path
WHERE
  (
    -- This list is the result of multiple queries combined and can likely be minimized
    file.path LIKE '/dev/%%'
    OR file.path LIKE '/dev/%%/%%'
    OR file.path LIKE '/dev/mqueue/%%'
    OR file.path LIKE '/dev/mqueue/.%/%%'
    OR file.path LIKE '/dev/mqueue/%/%%'
    OR file.path LIKE '/dev/mqueue/%/%/.%'
    OR file.path LIKE '/dev/mqueue/%/.%/%%'
    OR file.path LIKE '/dev/shm/%%'
    OR file.path LIKE '/dev/shm/.%/%%'
    OR file.path LIKE '/dev/shm/%/%%'
    OR file.path LIKE '/dev/shm/%/%/.%'
    OR file.path LIKE '/dev/shm/%/.%/%%'
  )
  AND file.type = 'regular'
  AND file.path NOT LIKE '%/../%'
  AND file.path NOT LIKE '%/./%'
  AND (
    file.mode LIKE '%7%'
    or file.mode LIKE '%5%'
    or file.mode LIKE '%1%'
  )
