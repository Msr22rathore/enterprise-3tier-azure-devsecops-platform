import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Task, CreateTask } from '../../core/models/task.model';
import { TaskService } from '../../core/services/task.service';

@Component({
  selector: 'app-tasks',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="hero">
      <div>
        <h2>Tasks</h2>
        <p>
          Angular → API → Service → Repository → EF Core → SQL Server.
        </p>
      </div>
    </div>

    <form class="card form" (ngSubmit)="create()">

      <input
        [(ngModel)]="draft.title"
        name="title"
        placeholder="Task title"
        required>

      <input
        [(ngModel)]="draft.description"
        name="description"
        placeholder="Description">

      <select
        [(ngModel)]="draft.priority"
        name="priority">

        <option [ngValue]="1">P1</option>
        <option [ngValue]="2">P2</option>
        <option [ngValue]="3">P3</option>
        <option [ngValue]="4">P4</option>
        <option [ngValue]="5">P5</option>

      </select>

      <button class="button" type="submit">
        Create
      </button>

    </form>

    <p class="error">{{ error }}</p>

    <div class="table">

      <table>

        <thead>
          <tr>
            <th>ID</th>
            <th>Task</th>
            <th>Status</th>
            <th>Priority</th>
            <th>Owner</th>
            <th></th>
          </tr>
        </thead>

        <tbody>

          <tr *ngFor="let t of tasks">

            <td>{{ t.id }}</td>

            <td>
              <b>{{ t.title }}</b>
              <br>
              <small>{{ t.description }}</small>
            </td>

            <td>

              <select
                [ngModel]="t.status"
                (ngModelChange)="change(t, $event)">

                <option>Pending</option>
                <option>InProgress</option>
                <option>Completed</option>
                <option>Blocked</option>

              </select>

            </td>

            <td>{{ t.priority }}</td>

            <td>{{ t.userName }}</td>

            <td>
              <button
                class="danger"
                type="button"
                (click)="archive(t.id)">
                Archive
              </button>
            </td>

          </tr>

        </tbody>

      </table>

    </div>
  `
})
export class TasksComponent implements OnInit {

  private svc = inject(TaskService);

  tasks: Task[] = [];

  error = '';

  // Temporary local-development user.
  // This will later come from authentication/Entra ID.
  draft: CreateTask = {
    title: '',
    description: '',
    priority: 3,
    userId: 1
  };

  ngOnInit() {
    this.load();
  }

  load() {

    this.error = '';

    this.svc.getAll().subscribe({

      next: x => {
        this.tasks = x;
      },

      error: e => {
        this.error = `API unavailable (${e.status ?? 'error'})`;
      }

    });
  }

  create() {

    this.error = '';

    this.svc.create(this.draft).subscribe({

      next: () => {

        this.draft = {
          title: '',
          description: '',
          priority: 3,
          userId: 1
        };

        this.load();
      },

      error: e => {

        console.error('Create task failed:', e);

        this.error =
          e.error?.message ??
          e.error?.title ??
          'Create failed';

      }

    });
  }

  change(t: Task, status: string) {

    this.svc.update(
      t.id,
      {
        title: t.title,
        description: t.description,
        priority: t.priority,
        status
      }
    ).subscribe({

      next: x => {
        Object.assign(t, x);
      },

      error: e => {

        console.error('Update task failed:', e);

        this.load();
      }

    });
  }

  archive(id: number) {

    this.svc.archive(id).subscribe({

      next: () => {
        this.load();
      },

      error: e => {

        console.error('Archive task failed:', e);

        this.load();
      }

    });
  }
}