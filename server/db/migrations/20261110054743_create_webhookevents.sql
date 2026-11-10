
-- migrate:up

-- Required for the composite foreign key below.
ALTER TABLE payments
ADD CONSTRAINT uq_payments_business_payment
UNIQUE (fk_business, pk_payment);


CREATE TABLE webhook_events (
    pk_webhook_event UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    fk_business UUID,
    fk_payment UUID,

    stripe_event_id TEXT NOT NULL UNIQUE,
    stripe_account_id TEXT,

    event_type TEXT NOT NULL,

    event_status TEXT NOT NULL DEFAULT 'received',

    event_payload JSONB NOT NULL,

    processing_attempts INTEGER NOT NULL DEFAULT 0,
    last_processing_error TEXT,

    event_received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    event_processed_at TIMESTAMPTZ,

    -- Associated business, if applicable
    CONSTRAINT fk_webhook_events_business
        FOREIGN KEY (fk_business)
        REFERENCES businesses (pk_business),

    -- Payment must belong to the same business
    CONSTRAINT fk_webhook_events_business_payment
        FOREIGN KEY (fk_business, fk_payment)
        REFERENCES payments (fk_business, pk_payment),

    CONSTRAINT chk_webhook_event_status
        CHECK (
            event_status IN (
                'received',
                'processing',
                'processed',
                'failed'
            )
        ),

    CONSTRAINT chk_webhook_processing_attempts
        CHECK (processing_attempts >= 0),

    CONSTRAINT chk_webhook_processed_at
        CHECK (
            (event_status = 'processed' AND event_processed_at IS NOT NULL)
            OR
            (event_status != 'processed' AND event_processed_at IS NULL)
        ),

    CONSTRAINT chk_webhook_payment_requires_business
        CHECK (
            fk_payment IS NULL OR fk_business IS NOT NULL
        )
);


-- Find events belonging to a business
CREATE INDEX idx_webhook_events_business
ON webhook_events (fk_business);

-- Find events that need processing or retrying
CREATE INDEX idx_webhook_events_status_received
ON webhook_events (event_status, event_received_at);

-- Find events associated with a payment
CREATE INDEX idx_webhook_events_payment
ON webhook_events (fk_business, fk_payment)
WHERE fk_payment IS NOT NULL;


-- migrate:down
