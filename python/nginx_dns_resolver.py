'''
In this script:
- Open config file, located in 'file_path' in r+ mode (r/w).
- readlines - read file line by line.
- Using while check lines.
- In lines search DNS using regexp.
- Function resolve_dns resolved DNS to IP using socket.gethostbyname
- If DNS name can't be resolved for line this line will be delete.
- Finally rewrite line in the config file

'''
#!/usr/bin/env python3

import re
import socket

# Function to resolve DNS names to IP addresses
def resolve_dns(name):
    try:
        ip_address = socket.gethostbyname(name)
        return ip_address
    except socket.gaierror:
        return None

# Path to the file
file_path = '/etc/nginx/conf.d/nginx_config_allow.conf'

# Open the file for reading and writing
with open(file_path, 'r+') as file:
    # Read the lines of the file
    lines = file.readlines()

    # Iterate over each line
    i = 0
    while i < len(lines):
        line = lines[i]
        # Check if the line contains a DNS name (assuming it follows the 'allow <name>;' pattern)
        match = re.match(r'^allow ([a-zA-Z0-9.-]+);$', line.strip())
        if match:
            dns_name = match.group(1)
            # Resolve the DNS name to an IP address
            ip_address = resolve_dns(dns_name)
            if ip_address:
                # Replace the DNS name with the IP address in the line
                updated_line = f'allow {ip_address};\n'
                lines[i] = updated_line
                i += 1
            else:
                # Remove the line if DNS resolution fails
                del lines[i]
        else:
            i += 1

    # Move the file pointer to the beginning of the file
    file.seek(0)
    # Write the updated lines back to the file
    file.writelines(lines)
    # Truncate any remaining content in the file (if the new content is shorter than the old content)
    file.truncate()