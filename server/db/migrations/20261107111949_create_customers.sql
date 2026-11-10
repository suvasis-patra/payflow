-- migrate:up
CREATE TABLE customers(
      pk_customer UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      customer_created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
      customer_updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

      fk_business UUID NOT NULL,

      customer_name TEXT NOT NULL,
      customer_email TEXT NOT NULL,
      customer_stripe_id TEXT,

      -- This constrain make sure every customer belongs to a business
      CONSTRAINT fk_customers_business
         FOREIGN KEY (fk_business)
         REFERENCES businesses (pk_business),

      -- Prevent duplicate customer emails within the same business
      CONSTRAINT uq_customers_business_email
         UNIQUE (fk_business, customer_email),

      -- Supports composite foreign keys in the payments table
      CONSTRAINT uq_customers_business_customer
         UNIQUE (fk_business, pk_customer),

      -- Prevent one Stripe customer from mapping to multiple PayFlow customers
      CONSTRAINT uq_customers_stripe_id
         UNIQUE (customer_stripe_id)

);

CREATE TRIGGER set_updated_at_customers
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION trigger_set_updated_at();

-- migrate:down

