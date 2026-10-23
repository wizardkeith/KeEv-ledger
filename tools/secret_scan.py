#!/usr/bin/env python3
"""Conservative source scan; only reports filename, line, pattern category."""
from pathlib import Path
import re
import sys

root=Path(__file__).resolve().parents[1]
patterns={
  'private-key': re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----'),
  'service-role-assignment': re.compile(r'(?i)(?:SUPABASE_SERVICE_ROLE_KEY|service_role)\s*[:=]\s*["\x27]eyJ[A-Za-z0-9_-]{40,}'),
  'cloud-key-assignment': re.compile(r'(?i)"private_key"\s*:\s*"-----BEGIN'),
  'credential-url': re.compile(r'(?i)postgres(?:ql)?://[^\s:@/]+:[^\s@/]+@'),
  'secret-assignment': re.compile(r'(?i)(?:client_secret|APPLE_IAP_PRIVATE_KEY|GOOGLE_SERVICE_ACCOUNT_JSON)\s*[:=]\s*["\x27](?!\$|<|PLACEHOLDER)[A-Za-z0-9_+/=\\n-]{40,}'),
}
extensions={'.dart','.ts','.mjs','.sql','.swift','.kt','.kts','.json','.yaml','.yml','.toml','.md','.plist','.xml'}
findings=[]
for path in root.rglob('*'):
  if not path.is_file() or path.suffix not in extensions: continue
  if any(part in {'.git','.dart_tool','build','.pub-cache','node_modules'} for part in path.parts): continue
  for number,line in enumerate(path.read_text(errors='replace').splitlines(),1):
    if path.name in {'secret_scan.py','phase9_security_checks.py'}: continue
    for name,pattern in patterns.items():
      if pattern.search(line):findings.append((path.relative_to(root),number,name))
for path,line,name in findings:print(f'{path}:{line}: {name}')
if findings:sys.exit(1)
print('Secret scan: no high-confidence privileged credential in source')
