#!/bin/bash

useradd -m -U admin
mkdir -p /home/admin/.ssh
cat >> /home/admin/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB1LqUEmMgmnhVGlECS+WsjWtG+KpWpVSvGKVWSXHOzWDzJXo4n0q/7IY6avZJeKEaNb58a7ZKzN3CnO/VVArvb5MW3R+JXsCIs57pyAPtVF8yjybhmdnBL2sYvfZf7mUWEUY13sOghC1PuiWkMX3QKohG9mMWkagQn/RZJyHh3zO9Xl2QWMXmShtEmHQEw9udjhk1WE8Ga9yTZ5XLuSn0+yRm3DgQsJ65XFu2wYWmf8ty3WX+CEeBcb73Gdp/iUKHfz+Ijw7cyyHbyPAf4FriL71u0hRXYsqNnfLJSzJcY2rnzMOpAgt8N6Krjjs2bHYlvKSUUb3wQx4C3sNDEJTL admin@viz-cluster
EOF
chmod -R go- /home/admin/.ssh
chown -R admin:admin /home/admin/.ssh

