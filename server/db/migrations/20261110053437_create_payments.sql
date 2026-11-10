-- migrate:up
CREATE TABLE payments (
    pk_payment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_paid_at TIMESTAMPTZ,

    fk_business UUID NOT NULL,
    fk_customer UUID NOT NULL,

    payment_amount BIGINT NOT NULL,
    payment_currency TEXT NOT NULL,
    payment_description TEXT,

    payment_status TEXT NOT NULL DEFAULT 'pending',

    idempotency_key TEXT NOT NULL,
    request_hash TEXT NOT NULL,

    stripe_checkout_session_id TEXT UNIQUE,
    stripe_payment_intent_id TEXT UNIQUE,


    -- Business must exist
    CONSTRAINT fk_payments_business
        FOREIGN KEY (fk_business)
        REFERENCES businesses (pk_business),

    -- Customer must belong to the same business
    CONSTRAINT fk_payments_business_customer
        FOREIGN KEY (fk_business, fk_customer)
        REFERENCES customers (fk_business, pk_customer),

    -- Payment amount must be positive
    CONSTRAINT chk_payment_amount
        CHECK (payment_amount > 0),

    -- Currency must be a lowercase three-letter code
    CONSTRAINT chk_payment_currency
        CHECK (payment_currency ~ '^[a-z]{3}$'),

    -- Allowed payment statuses
    CONSTRAINT chk_payment_status
        CHECK (
            payment_status IN (
                'pending',
                'processing',
                'succeeded',
                'failed',
                'expired'
            )
        ),

    -- Idempotency key must not be empty
    CONSTRAINT chk_payment_idempotency_key
        CHECK (LENGTH(TRIM(idempotency_key)) > 0),

    -- Same idempotency key cannot be reused within a business
    CONSTRAINT uq_payments_business_idempotency
        UNIQUE (fk_business, idempotency_key)
);


-- Index for retrieving payments belonging to a business
CREATE INDEX idx_payments_business
ON payments (fk_business);

-- Index for retrieving payments belonging to a customer
CREATE INDEX idx_payments_customer
ON payments (fk_business, fk_customer);

-- Index for filtering payments by status
CREATE INDEX idx_payments_status
ON payments (fk_business, payment_status);

CREATE TRIGGER set_updated_at_payments
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION trigger_set_updated_at();

-- migrate:down

