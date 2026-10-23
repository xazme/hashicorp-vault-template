FROM hashicorp/vault:2.1.0

USER root

RUN mkdir -p /vault/data /vault/plugins/tmp \
    && chown -R vault:vault /vault

RUN printf '#!/bin/sh\n\
chown -R root:vault /vault/config/certs 2>/dev/null || true\n\
chmod 0640 /vault/config/certs/vault.key 2>/dev/null || true\n\
chmod 0644 /vault/config/certs/vault.pem /vault/config/certs/ca.pem 2>/dev/null || true\n\
exec /usr/local/bin/docker-entrypoint.sh "$@"\n' > /vault-chmod-entrypoint.sh \
    && chmod +x /vault-chmod-entrypoint.sh

ENTRYPOINT ["/vault-chmod-entrypoint.sh"]

CMD ["vault", "server", "-config=/vault/config/hcl/vault.hcl"]
