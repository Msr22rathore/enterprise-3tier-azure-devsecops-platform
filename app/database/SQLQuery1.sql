CREATE USER [id-ent3tier-dev] FROM EXTERNAL PROVIDER;

ALTER ROLE db_datareader
ADD MEMBER [id-ent3tier-dev];

ALTER ROLE db_datawriter
ADD MEMBER [id-ent3tier-dev];

SELECT
    USER_NAME(rp.principal_id) AS RoleName,
    USER_NAME(rm.member_principal_id) AS MemberName
FROM sys.database_role_members rm
JOIN sys.database_principals rp
    ON rm.role_principal_id = rp.principal_id
WHERE USER_NAME(rm.member_principal_id) = 'id-ent3tier-dev';