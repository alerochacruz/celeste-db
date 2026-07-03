CREATE TABLE system_settings
(
    id            INT IDENTITY (1,1) NOT NULL,
    setting_key   VARCHAR(50)        NOT NULL,
    setting_value VARCHAR(100)       NULL,
    description   VARCHAR(500)       NULL,

    CONSTRAINT PK_system_settings PRIMARY KEY (id),
    CONSTRAINT UQ_system_settings_key UNIQUE (setting_key)
);




