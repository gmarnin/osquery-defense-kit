-- Pick out exotic processes based on their command-line (state-based)
--
-- false positives:
--   * possible, but none known
--
-- tags: transient process state
-- platform: posix
SELECT
  p.pid,
  p.path,
  p.name,
  p.cmdline AS cmd,
  p.cwd,
  p.euid,
  p.parent,
  pp.path AS parent_path,
  pp.name AS parent_name,
  pp.cmdline AS parent_cmd,
  pp.euid AS parent_euid,
  hash.sha256 AS child_sha256,
  phash.sha256 AS parent_sha256
FROM
  processes p
  LEFT JOIN processes pp ON p.parent = pp.pid
  LEFT JOIN hash ON p.path = hash.path
  LEFT JOIN hash AS phash ON pp.path = hash.path
WHERE
  -- Known attack scripts
  p.name IN ('nc', 'mkfifo')
  OR p.name LIKE '%pwn%'
  OR p.name LIKE '%xig%'
  OR p.name LIKE '%xmr%'
  OR cmd LIKE '%bitspin%'
  OR cmd LIKE '%lushput%'
  OR cmd LIKE '%incbit%'
  OR cmd LIKE '%traitor%'
  OR cmd LIKE '%msfvenom%'
  OR
  -- Unusual behaviors
  cmd LIKE '%ufw disable%'
  OR cmd LIKE '%iptables -P % ACCEPT%'
  OR cmd LIKE '%iptables -F%'
  OR cmd LIKE '%chattr -ia%'
  OR cmd LIKE '%chmod 777 %'
  OR cmd LIKE '%bpftool%'
  OR cmd LIKE '%touch%acmr%'
  OR cmd LIKE '%ld.so.preload%'
  OR cmd LIKE '%urllib.urlopen%'
  OR cmd LIKE '%nohup%tmp%'
  OR cmd LIKE '%set visible of front window to false%'
  OR cmd LIKE '%chrome%--load-extension%'
  OR
  -- Crypto miners
  cmd LIKE '%c3pool%'
  OR cmd LIKE '%cryptonight%'
  OR cmd LIKE '%f2pool%'
  OR cmd LIKE '%hashrate%'
  OR cmd LIKE '%hashvault%'
  OR cmd LIKE '%minerd%'
  OR cmd LIKE '%monero%'
  OR cmd LIKE '%nanopool%'
  OR cmd LIKE '%nicehash%'
  OR cmd LIKE '%stratum%'
  OR
  -- Random keywords
  cmd LIKE '%ransom%'
  OR cmd LIKE '%malware%'
  OR cmd LIKE '%plant%'
  OR
  -- Reverse shells
  cmd LIKE '%/dev/tcp/%'
  OR cmd LIKE '%/dev/udp/%'
  OR cmd LIKE '%fsockopen%'
  OR cmd LIKE '%openssl%quiet%'
  OR cmd LIKE '%pty.spawn%'
  OR cmd LIKE '%sh -i'
  OR cmd LIKE '%socat%'
  OR cmd LIKE '%SOCK_STREAM%'
  OR cmd LIKE '%Socket.fork%'
  OR cmd LIKE '%Socket.new%'
  OR cmd LIKE '%socket.socket%'
