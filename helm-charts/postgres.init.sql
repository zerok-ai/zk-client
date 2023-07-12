CREATE DATABASE pl;

\c pl;

CREATE TABLE IF NOT EXISTS scenario (
    scenario_id    SERIAL PRIMARY KEY,
    cluster_id     VARCHAR(255),
    scenario_title VARCHAR(255),
    disabled       BOOL DEFAULT FALSE,
    disabled_by    VARCHAR(255) DEFAULT NULL,
    disabled_at    BIGINT DEFAULT NULL,
    scenario_type  VARCHAR(50),
    is_default 	   BOOLEAN DEFAULT false,
    deleted        BOOLEAN DEFAULT FALSE,
    deleted_by     VARCHAR(255) DEFAULT NULL,
    deleted_at     BIGINT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS scenario_version (
    scenario_version_id  SERIAL PRIMARY KEY,
    scenario_id          INTEGER REFERENCES scenario (scenario_id),
    scenario_data        BYTEA,
    schema_version       VARCHAR(255),
    scenario_version     BIGINT,
    created_by           VARCHAR(255),
    created_at           BIGINT
);

INSERT INTO scenario_version (scenario_id, scenario_data, schema_version, scenario_version, created_by, created_at)
VALUES (1, '{"version":"1684149787","workloads":{"55661a0e-25cb-5a1c-94cd-fad172b0caa2":{"service":"*/*","trace_role":"server","protocol":"HTTP","rule":{"type":"rule_group","condition":"AND","rules":[{"type":"rule","id":"req_method","field":"req_method","datatype":"string","input":"string","operator":"equal","value":"POST"},{"type":"rule","id":"req_path","field":"req_path","datatype":"string","input":"string","operator":"equal","value":"/exception"}]}}},"scenario_id":"1","filter":{"type":"workload","condition":"AND","workload_ids":["55661a0e-25cb-5a1c-94cd-fad172b0caa2"]},"group_by":[{"workload_id": "55661a0e-25cb-5a1c-94cd-fad172b0caa2","title":"destination","hash":"destination"}]}', 'v1', 1687763051, 'vaibhav ', 1687763051);

INSERT INTO scenario_version (scenario_id, scenario_data, schema_version, scenario_version, created_by, created_at)
VALUES (2, '{"version":"1684149744","workloads":{"4daf52e6-a3a6-530f-9f3e-e9b88ed25641":{"service":"*/*","trace_role":"server","protocol":"HTTP","rule":{"type":"rule_group","condition":"AND","rules":[{"type":"rule","id":"resp_status","field":"resp_status","datatype":"integer","input":"integer","operator":"greater_than","value":"199"}]}}},"scenario_id":"2","filter":{"type":"workload","condition":"OR","workload_ids":["4daf52e6-a3a6-530f-9f3e-e9b88ed25641"]},"group_by":[{"workload_id": "4daf52e6-a3a6-530f-9f3e-e9b88ed25641","title":"destination","hash":"destination"}]}', 'v1', 1687763051, 'vaibhav ', 1687763051);

CREATE TABLE IF NOT EXISTS issue (
    id              SERIAL PRIMARY KEY,
    issue_hash      VARCHAR(255) UNIQUE,
    issue_title     VARCHAR(255),
    scenario_id     VARCHAR(255),
    scenario_version VARCHAR(255)
);

CREATE TABLE incident (
    id SERIAL PRIMARY KEY,
    issue_hash        VARCHAR(255),
    trace_id VARCHAR(40),
    incident_collection_time TIMESTAMP,
    CONSTRAINT unique_issue UNIQUE (issue_hash, trace_id)
);

CREATE TABLE IF NOT EXISTS span (
    id                SERIAL PRIMARY KEY,
    trace_id          VARCHAR(255),
    span_id           VARCHAR(255),
    parent_span_id    VARCHAR(255),
    source            VARCHAR(255),
    destination       VARCHAR(255),
    workload_id_list  TEXT[],
    status            VARCHAR(255),
    metadata          TEXT,
    latency_ms        FLOAT,
    protocol          VARCHAR(255),
    issue_hash_list  TEXT[],
    time TIMESTAMP,
    CONSTRAINT unique_span UNIQUE (trace_id, span_id)
);

CREATE TABLE IF NOT EXISTS span_raw_data (
    id                SERIAL PRIMARY KEY,
    trace_id          VARCHAR(255),
    span_id           VARCHAR(255),
    request_payload   BYTEA,
    response_payload  BYTEA,
    CONSTRAINT unique_span_raw_data UNIQUE (trace_id, span_id)
);