import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of, throwError } from 'rxjs';

import { DashboardComponent } from './dashboard.component';
import { TaskService } from '../../core/services/task.service';
import { Task } from '../../core/models/task.model';

describe('DashboardComponent', () => {
  let component: DashboardComponent;
  let fixture: ComponentFixture<DashboardComponent>;
  let taskService: jasmine.SpyObj<TaskService>;

  const tasks: Task[] = [
    {
      id: 1,
      title: 'Pending Task',
      description: 'Pending description',
      status: 'Pending',
      priority: 3,
      createdAt: '2026-08-15T10:00:00Z',
      userId: 1,
      userName: 'User One',
      userEmail: 'user1@example.com'
    },
    {
      id: 2,
      title: 'In Progress Task',
      description: 'In progress description',
      status: 'InProgress',
      priority: 2,
      createdAt: '2026-08-15T11:00:00Z',
      userId: 1,
      userName: 'User One',
      userEmail: 'user1@example.com'
    },
    {
      id: 3,
      title: 'Completed Task',
      description: 'Completed description',
      status: 'Completed',
      priority: 1,
      createdAt: '2026-08-15T12:00:00Z',
      userId: 2,
      userName: 'User Two',
      userEmail: 'user2@example.com'
    },
    {
      id: 4,
      title: 'Another Pending Task',
      description: 'Another pending description',
      status: 'Pending',
      priority: 4,
      createdAt: '2026-08-15T13:00:00Z',
      userId: 2,
      userName: 'User Two',
      userEmail: 'user2@example.com'
    }
  ];

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('TaskService', ['getAll']);

    await TestBed.configureTestingModule({
      imports: [DashboardComponent],
      providers: [
        {
          provide: TaskService,
          useValue: spy
        },
        provideRouter([])
      ]
    }).compileComponents();

    taskService = TestBed.inject(
      TaskService
    ) as jasmine.SpyObj<TaskService>;
  });

  it('should create', () => {
    taskService.getAll.and.returnValue(of([]));

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;

    expect(component).toBeTruthy();
  });

  it('should calculate task summary correctly', (done) => {
    taskService.getAll.and.returnValue(of(tasks));

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;

    component.summary$.subscribe(summary => {
      expect(summary.total).toBe(4);
      expect(summary.pending).toBe(2);
      expect(summary.inProgress).toBe(1);
      expect(summary.completed).toBe(1);

      done();
    });
  });

  it('should return zero counts when the API fails', (done) => {
    taskService.getAll.and.returnValue(
      throwError(() => new Error('API unavailable'))
    );

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;

    component.summary$.subscribe(summary => {
      expect(summary.total).toBe(0);
      expect(summary.pending).toBe(0);
      expect(summary.inProgress).toBe(0);
      expect(summary.completed).toBe(0);

      done();
    });
  });

  it('should call TaskService getAll', () => {
    taskService.getAll.and.returnValue(of(tasks));

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;

    component.summary$.subscribe();

    expect(taskService.getAll).toHaveBeenCalled();
  });
});