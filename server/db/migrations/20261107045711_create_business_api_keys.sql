-- migrate:up
CREATE TABLE business_api_keys(
      pk_business_api_key UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      api_key_created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

      fk_business UUID NOT NULL,

      api_key_name TEXT NOT NULL,
      api_key_prefix TEXT NOT NULL UNIQUE,
      api_key_hash TEXT NOT NULL UNIQUE,

      api_key_last_used_at TIMESTAMPTZ,
      api_key_expires_at TIMESTAMPTZ,
      api_key_revoked_at TIMESTAMPTZ,

      CONSTRAINT fk_api_keys_business
         FOREIGN KEY (fk_business)
         REFERENCES businesses (pk_business)
         ON DELETE CASCADE,

      CONSTRAINT chk_api_key_expiry
        CHECK (
            api_key_expires_at IS NULL
            OR api_key_expires_at > api_key_created_at
        )   
);


CREATE INDEX idx_api_keys_business
ON business_api_keys(fk_business);

-- migrate:down

