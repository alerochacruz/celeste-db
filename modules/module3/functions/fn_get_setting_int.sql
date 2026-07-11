SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER FUNCTION fn_get_setting_int
(
    @setting_key   VARCHAR(50),
    @default_value INT
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT;

    SELECT @result = TRY_CAST(setting_value AS INT)
    FROM system_settings
    WHERE setting_key = @setting_key;

    RETURN ISNULL(@result, @default_value);
END;
GO