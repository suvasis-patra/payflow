-- migrate:up
CREATE TABLE businesses(
      pk_business UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

      business_name TEXT NOT NULL,
      business_email TEXT NOT NULL UNIQUE,
      stripe_account_id TEXT UNIQUE,
      charges_enabled BOOLEAN NOT NULL DEFAULT FALSE,
      payouts_enabled BOOLEAN NOT NULL DEFAULT FALSE,
      onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE
);



CREATE TRIGGER set_updated_at_businesses
    BEFORE UPDATE ON businesses
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- migrate:down

