using EnterpriseTask.Api.DTOs.Tasks;
using EnterpriseTask.Api.Models;
using EnterpriseTask.Api.Repositories.Interfaces;
using EnterpriseTask.Api.Services;
using Moq;

namespace EnterpriseTask.Api.Tests;

public class TaskServiceTests
{
    private readonly Mock<ITaskRepository> _repositoryMock;
    private readonly TaskService _service;

    public TaskServiceTests()
    {
        _repositoryMock = new Mock<ITaskRepository>();
        _service = new TaskService(_repositoryMock.Object);
    }

    [Fact]
    public async Task GetByIdAsync_WhenTaskExists_ReturnsTask()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "Sunny",
            Email = "sunny@example.com"
        };

        var task = new TaskItem
        {
            Id = 10,
            Title = "Deploy application",
            Description = "Deploy application to AKS",
            Status = "Pending",
            Priority = 2,
            UserId = 1,
            User = user
        };

        _repositoryMock
            .Setup(r => r.GetByIdAsync(10, It.IsAny<CancellationToken>()))
            .ReturnsAsync(task);

        // Act
        var result = await _service.GetByIdAsync(
            10,
            CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(10, result.Id);
        Assert.Equal("Deploy application", result.Title);
        Assert.Equal("Pending", result.Status);
        Assert.Equal(2, result.Priority);
        Assert.Equal("Sunny", result.UserName);
        Assert.Equal("sunny@example.com", result.UserEmail);

        _repositoryMock.Verify(
            r => r.GetByIdAsync(10, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task GetByIdAsync_WhenTaskDoesNotExist_ReturnsNull()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.GetByIdAsync(999, It.IsAny<CancellationToken>()))
            .ReturnsAsync((TaskItem?)null);

        // Act
        var result = await _service.GetByIdAsync(
            999,
            CancellationToken.None);

        // Assert
        Assert.Null(result);

        _repositoryMock.Verify(
            r => r.GetByIdAsync(999, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsMappedTasks()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "Sunny",
            Email = "sunny@example.com"
        };

        var tasks = new List<TaskItem>
        {
            new()
            {
                Id = 1,
                Title = "Task One",
                Description = "First task",
                Status = "Pending",
                Priority = 1,
                UserId = 1,
                User = user
            },
            new()
            {
                Id = 2,
                Title = "Task Two",
                Description = "Second task",
                Status = "Completed",
                Priority = 2,
                UserId = 1,
                User = user
            }
        };

        _repositoryMock
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(tasks);

        // Act
        var result = await _service.GetAllAsync(
            CancellationToken.None);

        // Assert
        Assert.Equal(2, result.Count);

        Assert.Equal("Task One", result[0].Title);
        Assert.Equal("Pending", result[0].Status);

        Assert.Equal("Task Two", result[1].Title);
        Assert.Equal("Completed", result[1].Status);

        _repositoryMock.Verify(
            r => r.GetAllAsync(It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task CreateAsync_CreatesPendingTask()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "Sunny",
            Email = "sunny@example.com"
        };

        TaskItem? createdTask = null;

        _repositoryMock
            .Setup(r => r.AddAsync(
                It.IsAny<TaskItem>(),
                It.IsAny<CancellationToken>()))
            .Callback<TaskItem, CancellationToken>((task, _) =>
            {
                task.Id = 100;
                task.User = user;
                createdTask = task;
            })
            .Returns(Task.CompletedTask);

        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                100,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(() =>
            {
                createdTask!.User = user;
                return createdTask;
            });

        _repositoryMock
            .Setup(r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        var dto = new CreateTaskDto
        {
            Title = "  Deploy AKS  ",
            Description = "  Deploy application to AKS  ",
            Priority = 2,
            UserId = 1
        };

        // Act
        var result = await _service.CreateAsync(
            dto,
            CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(100, result.Id);
        Assert.Equal("Deploy AKS", result.Title);
        Assert.Equal(
            "Deploy application to AKS",
            result.Description);
        Assert.Equal("Pending", result.Status);
        Assert.Equal(2, result.Priority);
        Assert.Equal(1, result.UserId);

        Assert.NotNull(createdTask);
        Assert.Single(createdTask!.History);

        Assert.Equal(
            "Pending",
            createdTask.History.First().Status);

        _repositoryMock.Verify(
            r => r.AddAsync(
                It.IsAny<TaskItem>(),
                It.IsAny<CancellationToken>()),
            Times.Once);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Exactly(2));
    }

    [Fact]
    public async Task UpdateAsync_WhenTaskDoesNotExist_ReturnsNull()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                999,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync((TaskItem?)null);

        var dto = new UpdateTaskDto
        {
            Title = "Updated task",
            Description = "Updated description",
            Priority = 1,
            Status = "Completed"
        };

        // Act
        var result = await _service.UpdateAsync(
            999,
            dto,
            CancellationToken.None);

        // Assert
        Assert.Null(result);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task UpdateAsync_WhenStatusChanges_AddsHistory()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "Sunny",
            Email = "sunny@example.com"
        };

        var task = new TaskItem
        {
            Id = 20,
            Title = "Old title",
            Description = "Old description",
            Status = "Pending",
            Priority = 3,
            UserId = 1,
            User = user
        };

        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                20,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(task);

        _repositoryMock
            .Setup(r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        var dto = new UpdateTaskDto
        {
            Title = "Updated title",
            Description = "Updated description",
            Priority = 1,
            Status = "Completed"
        };

        // Act
        var result = await _service.UpdateAsync(
            20,
            dto,
            CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Updated title", result.Title);
        Assert.Equal("Updated description", result.Description);
        Assert.Equal("Completed", result.Status);
        Assert.Equal(1, result.Priority);

        Assert.Single(task.History);
        Assert.Equal("Completed", task.History.First().Status);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ArchiveAsync_WhenTaskExists_SetsBlocked()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "Sunny",
            Email = "sunny@example.com"
        };

        var task = new TaskItem
        {
            Id = 30,
            Title = "Task",
            Description = "Task description",
            Status = "Pending",
            Priority = 2,
            UserId = 1,
            User = user
        };

        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                30,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(task);

        _repositoryMock
            .Setup(r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _service.ArchiveAsync(
            30,
            CancellationToken.None);

        // Assert
        Assert.True(result);
        Assert.Equal("Blocked", task.Status);

        Assert.Single(task.History);
        Assert.Equal(
            "Blocked",
            task.History.First().Status);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ArchiveAsync_WhenTaskDoesNotExist_ReturnsFalse()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                999,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync((TaskItem?)null);

        // Act
        var result = await _service.ArchiveAsync(
            999,
            CancellationToken.None);

        // Assert
        Assert.False(result);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task DeleteAsync_WhenTaskExists_DeletesTask()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "Sunny",
            Email = "sunny@example.com"
        };

        var task = new TaskItem
        {
            Id = 40,
            Title = "Delete me",
            Description = "Task",
            Status = "Pending",
            Priority = 3,
            UserId = 1,
            User = user
        };

        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                40,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(task);

        _repositoryMock
            .Setup(r => r.DeleteAsync(
                task,
                It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _repositoryMock
            .Setup(r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _service.DeleteAsync(
            40,
            CancellationToken.None);

        // Assert
        Assert.True(result);

        _repositoryMock.Verify(
            r => r.DeleteAsync(
                task,
                It.IsAny<CancellationToken>()),
            Times.Once);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task DeleteAsync_WhenTaskDoesNotExist_ReturnsFalse()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.GetByIdAsync(
                999,
                It.IsAny<CancellationToken>()))
            .ReturnsAsync((TaskItem?)null);

        // Act
        var result = await _service.DeleteAsync(
            999,
            CancellationToken.None);

        // Assert
        Assert.False(result);

        _repositoryMock.Verify(
            r => r.DeleteAsync(
                It.IsAny<TaskItem>(),
                It.IsAny<CancellationToken>()),
            Times.Never);

        _repositoryMock.Verify(
            r => r.SaveChangesAsync(
                It.IsAny<CancellationToken>()),
            Times.Never);
    }
}