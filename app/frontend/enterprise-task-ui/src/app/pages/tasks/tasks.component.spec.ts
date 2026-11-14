import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';

import { TasksComponent } from './tasks.component';
import { TaskService } from '../../core/services/task.service';
import { Task } from '../../core/models/task.model';

describe('TasksComponent', () => {
  let component: TasksComponent;
  let fixture: ComponentFixture<TasksComponent>;
  let taskService: jasmine.SpyObj<TaskService>;

  const tasks: Task[] = [
    {
      id: 1,
      title: 'Test Task',
      description: 'Test description',
      status: 'Pending',
      priority: 3,
      createdAt: '2026-08-15T10:00:00Z',
      userId: 1,
      userName: 'Test User',
      userEmail: 'test@example.com'
    }
  ];

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('TaskService', [
      'getAll',
      'create',
      'update',
      'archive'
    ]);

    await TestBed.configureTestingModule({
      imports: [TasksComponent],
      providers: [
        {
          provide: TaskService,
          useValue: spy
        }
      ]
    }).compileComponents();

    taskService = TestBed.inject(
      TaskService
    ) as jasmine.SpyObj<TaskService>;

    fixture = TestBed.createComponent(TasksComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load tasks on initialization', () => {
    taskService.getAll.and.returnValue(of(tasks));

    component.ngOnInit();

    expect(taskService.getAll).toHaveBeenCalled();
    expect(component.tasks).toEqual(tasks);
  });

  it('should show an error when loading tasks fails', () => {
    taskService.getAll.and.returnValue(
      throwError(() => ({ status: 500 }))
    );

    component.load();

    expect(component.error).toBe('API unavailable (500)');
  });

  it('should create a task and reload the list', () => {
    const createdTask = tasks[0];

    taskService.create.and.returnValue(of(createdTask));
    taskService.getAll.and.returnValue(of(tasks));

    component.draft = {
      title: 'New Task',
      description: 'New Description',
      priority: 2,
      userId: 1
    };

    component.create();

    expect(taskService.create).toHaveBeenCalledWith({
      title: 'New Task',
      description: 'New Description',
      priority: 2,
      userId: 1
    });

    expect(component.draft).toEqual({
      title: '',
      description: '',
      priority: 3,
      userId: 1
    });

    expect(taskService.getAll).toHaveBeenCalled();
  });

  it('should show an error when creating a task fails', () => {
    taskService.create.and.returnValue(
      throwError(() => ({
        error: {
          message: 'Create failed'
        }
      }))
    );

    component.create();

    expect(component.error).toBe('Create failed');
  });

  it('should update a task when status changes', () => {
    const task = { ...tasks[0] };

    const updatedTask: Task = {
      ...task,
      status: 'Completed'
    };

    taskService.update.and.returnValue(of(updatedTask));

    component.change(task, 'Completed');

    expect(taskService.update).toHaveBeenCalledWith(
      1,
      {
        title: 'Test Task',
        description: 'Test description',
        priority: 3,
        status: 'Completed'
      }
    );

    expect(task.status).toBe('Completed');
  });

  it('should reload tasks when updating fails', () => {
    const task = { ...tasks[0] };

    taskService.update.and.returnValue(
      throwError(() => new Error('Update failed'))
    );

    taskService.getAll.and.returnValue(of(tasks));

    component.change(task, 'Completed');

    expect(taskService.getAll).toHaveBeenCalled();
  });

  it('should archive a task and reload the list', () => {
    taskService.archive.and.returnValue(of(undefined));
    taskService.getAll.and.returnValue(of(tasks));

    component.archive(1);

    expect(taskService.archive).toHaveBeenCalledWith(1);
    expect(taskService.getAll).toHaveBeenCalled();
  });

  it('should reload tasks when archiving fails', () => {
    taskService.archive.and.returnValue(
      throwError(() => new Error('Archive failed'))
    );

    taskService.getAll.and.returnValue(of(tasks));

    component.archive(1);

    expect(taskService.getAll).toHaveBeenCalled();
  });
});