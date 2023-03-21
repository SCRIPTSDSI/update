IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'BUILTIN\Administrators')
CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS
GO
CREATE USER [BUILTIN\Administrators] FOR LOGIN [BUILTIN\Administrators]
GO
