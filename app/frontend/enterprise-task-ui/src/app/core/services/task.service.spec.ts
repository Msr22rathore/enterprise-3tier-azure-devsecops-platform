import { TestBed } from '@angular/core/testing';
import {
  HttpTestingController,
  provideHttpClientTesting
} from '@angular/common/http/testing';
import { provideHttpClient } from '@angular/common/http';

import { TaskService } from './task.service';
import { CreateTask, Task } from '../models/task.model';

describe('TaskService', () => {

  let service: TaskService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        TaskService,
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    });

    service = TestBed.inject(TaskService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should get all tasks', () => {

    const mockTasks: Task[] = [
      {
        id: 1,
        title: 'Test Task',
        description: 'Test description',
        status: 'Pending',
        priority: 3,
        createdAt: '2026-08-15T00:00:00Z',
        userId: 1,
        userName: 'Test User',
        userEmail: 'test@example.com'
      }
    ];

    service.getAll().subscribe(tasks => {
      expect(tasks.length).toBe(1);
      expect(tasks[0].id).toBe(1);
      expect(tasks[0].title).toBe('Test Task');
      expect(tasks[0].status).toBe('Pending');
    });

    const request = httpMock.expectOne('/api/tasks');

    expect(request.request.method).toBe('GET');

    request.flush(mockTasks);
  });

  it('should create a task', () => {

    const newTask: CreateTask = {
      title: 'New Task',
      description: 'New Description',
      priority: 2,
      userId: 1
    };

    const createdTask: Task = {
      id: 10,
      title: 'New Task',
      description: 'New Description',
      status: 'Pending',
      priority: 2,
      createdAt: '2026-08-15T00:00:00Z',
      userId: 1,
      userName: 'Test User',
      userEmail: 'test@example.com'
    };

    service.create(newTask).subscribe(task => {
      expect(task.id).toBe(10);
      expect(task.title).toBe('New Task');
      expect(task.status).toBe('Pending');
    });

    const request = httpMock.expectOne('/api/tasks');

    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual(newTask);

    request.flush(createdTask);
  });

  it('should update a task', () => {

    const update: Partial<Task> = {
      title: 'Updated Task',
      description: 'Updated description',
      priority: 1,
      status: 'Completed'
    };

    const updatedTask: Task = {
      id: 5,
      title: 'Updated Task',
      description: 'Updated description',
      status: 'Completed',
      priority: 1,
      createdAt: '2026-08-15T00:00:00Z',
      updatedAt: '2026-08-15T01:00:00Z',
      userId: 1,
      userName: 'Test User',
      userEmail: 'test@example.com'
    };

    service.update(5, update).subscribe(task => {
      expect(task.id).toBe(5);
      expect(task.status).toBe('Completed');
      expect(task.title).toBe('Updated Task');
    });

    const request = httpMock.expectOne('/api/tasks/5');

    expect(request.request.method).toBe('PUT');
    expect(request.request.body).toEqual(update);

    request.flush(updatedTask);
  });

it('should archive a task', () => {

  service.archive(7).subscribe();

  const request = httpMock.expectOne('/api/tasks/7');

  expect(request.request.method).toBe('DELETE');

  request.flush(null);

});
});