-- Reference schema. The application owns schema changes through EF Core.
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(120) NOT NULL,
    Email NVARCHAR(256) NOT NULL UNIQUE
);
CREATE TABLE Tasks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(2000) NOT NULL,
    Status NVARCHAR(30) NOT NULL,
    Priority INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL,
    UpdatedAt DATETIME2 NULL,
    UserId INT NOT NULL,
    CONSTRAINT FK_Tasks_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);
CREATE TABLE TaskHistory (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TaskId INT NOT NULL,
    Status NVARCHAR(30) NOT NULL,
    ChangedAt DATETIME2 NOT NULL,
    CONSTRAINT FK_TaskHistory_Tasks FOREIGN KEY (TaskId) REFERENCES Tasks(Id) ON DELETE CASCADE
);
