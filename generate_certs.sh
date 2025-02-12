#!/bin/bash

# Create directory structure
mkdir -p certs/ca
for node in es01 es02 es03; do
    mkdir -p certs/${node}
done

# Generate CA private key and certificate (no expiry)
openssl genrsa -out certs/ca/ca.key 4096
openssl req -x509 -new -nodes -key certs/ca/ca.key -sha256 -days 36500 -out certs/ca/ca.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=Elasticsearch CA"

# Create config file for SAN support
cat > certs/openssl.conf << 'EOF'
[req]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = US
ST = State
L = City
O = Organization
CN = NODE_NAME

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = NODE_NAME
DNS.2 = localhost
IP.1 = 127.0.0.1
IP.2 = 0.0.0.0
IP.3 = 192.168.107.2
IP.4 = 192.168.107.3
IP.5 = 192.168.107.4
EOF

# Generate certificates for each node
for node in es01 es02 es03; do
    echo "Generating certificates for ${node}"
    
    # Create node-specific config
    sed "s/NODE_NAME/${node}/g" certs/openssl.conf > certs/${node}/openssl.conf
    
    # Generate private key
    openssl genrsa -out certs/${node}/${node}.key 4096
    
    # Generate CSR with SAN
    openssl req -new -key certs/${node}/${node}.key -out certs/${node}/${node}.csr \
        -config certs/${node}/openssl.conf
    
    # Generate certificate (no expiry - 100 years)
    openssl x509 -req -in certs/${node}/${node}.csr \
        -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -CAcreateserial \
        -out certs/${node}/${node}.crt -days 36500 \
        -extensions req_ext -extfile certs/${node}/openssl.conf
    
    # Clean up CSR and node-specific config
    rm certs/${node}/${node}.csr certs/${node}/openssl.conf
done

# Remove main config file
rm certs/openssl.conf

# Set proper permissions
chmod 644 certs/ca/ca.crt
chmod 600 certs/ca/ca.key
for node in es01 es02 es03; do
    chmod 644 certs/${node}/${node}.crt
    chmod 600 certs/${node}/${node}.key
done

echo "Certificate generation complete. Directory structure:"
tree certs/
