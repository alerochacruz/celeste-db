USE celeste;
GO

CREATE USER datear FOR LOGIN datear;
ALTER ROLE db_owner ADD MEMBER datear;
GO
