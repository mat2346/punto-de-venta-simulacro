import { Component, OnInit, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProfesorService } from '../../../core/services/profesor.sevice';

interface Destinatario {
  id: number;
  nombre: string;
  codigo: string;
  tiene_fcm_token: boolean;
  estudiante_asociado?: string;
}

interface DestinatariosResponse {
  estudiantes: Destinatario[];
  tutores: Destinatario[];
  materia_info?: {
    id: number;
    nombre: string;
  };
}

@Component({
  standalone: true,
  selector: 'app-notificaciones',
  imports: [CommonModule, FormsModule],
  template: `
    <div class="bg-white rounded-lg shadow p-6">
      <h2 class="text-xl font-bold mb-4 text-gray-800">📱 Enviar Notificaciones</h2>

      <!-- Filtros -->
      <div class="mb-4 space-y-3">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Filtrar por materia (opcional)
          </label>
          <select 
            [(ngModel)]="selectedMateria" 
            (change)="cargarDestinatarios()"
            class="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500">
            <option value="">Todos los estudiantes y tutores</option>
            <option *ngFor="let materia of materias" [value]="materia.detalle_id">
              {{materia.materia}} - {{materia.curso}} {{materia.paralelo}}
            </option>
          </select>
        </div>
      </div>

      <!-- Información de la materia seleccionada -->
      <div *ngIf="destinatarios?.materia_info as materia" class="mb-4 p-3 bg-blue-50 rounded-md">
        <p class="text-sm text-blue-800">
          📚 Enviando a estudiantes y tutores de: <strong>{{materia.nombre}}</strong>
        </p>
      </div>

      <!-- Seleccionar destinatarios -->
      <div class="mb-4">
        <h3 class="text-lg font-semibold mb-2 text-gray-800">👥 Seleccionar Destinatarios</h3>
        
        <div class="flex gap-4 mb-3">
          <button 
            (click)="seleccionarTodos()" 
            class="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700">
            Seleccionar Todos
          </button>
          <button 
            (click)="deseleccionarTodos()" 
            class="px-3 py-1 bg-gray-600 text-white rounded text-sm hover:bg-gray-700">
            Deseleccionar Todos
          </button>
          <button 
            (click)="seleccionarSoloEstudiantes()" 
            class="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700">
            Solo Estudiantes
          </button>
          <button 
            (click)="seleccionarSoloTutores()" 
            class="px-3 py-1 bg-purple-600 text-white rounded text-sm hover:bg-purple-700">
            Solo Tutores
          </button>
        </div>

        <!-- Lista de Estudiantes y Tutores -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div *ngIf="getEstudiantes().length > 0">
            <h4 class="font-medium text-gray-700 mb-2">🎓 Estudiantes ({{getEstudiantes().length}})</h4>
            <div class="max-h-48 overflow-y-auto border border-gray-200 rounded p-2">
              <label *ngFor="let estudiante of getEstudiantes()" 
                     class="flex items-center space-x-2 p-1 hover:bg-gray-50 rounded">
                <input 
                  type="checkbox" 
                  [value]="estudiante.id"
                  [checked]="isDestinatarioSeleccionado(estudiante.id)"
                  (change)="toggleDestinatario(estudiante.id, $event)"
                  class="rounded border-gray-300">
                <span class="text-sm flex-1">
                  {{estudiante.nombre}} ({{estudiante.codigo}})
                  <span *ngIf="!estudiante.tiene_fcm_token" class="text-red-500 text-xs">⚠️ Sin FCM</span>
                  <span *ngIf="estudiante.tiene_fcm_token" class="text-green-500 text-xs">📱</span>
                </span>
              </label>
            </div>
          </div>

          <!-- Lista de Tutores -->
          <div *ngIf="getTutores().length > 0">
            <h4 class="font-medium text-gray-700 mb-2">👨‍👩‍👧‍👦 Tutores ({{getTutores().length}})</h4>
            <div class="max-h-48 overflow-y-auto border border-gray-200 rounded p-2">
              <label *ngFor="let tutor of getTutores()" 
                     class="flex items-center space-x-2 p-1 hover:bg-gray-50 rounded">
                <input 
                  type="checkbox" 
                  [value]="tutor.id"
                  [checked]="isDestinatarioSeleccionado(tutor.id)"
                  (change)="toggleDestinatario(tutor.id, $event)"
                  class="rounded border-gray-300">
                <span class="text-sm flex-1">
                  {{tutor.nombre}} ({{tutor.codigo}})
                  <span *ngIf="tutor.estudiante_asociado" class="text-gray-500 text-xs">
                    - Tutor de {{tutor.estudiante_asociado}}
                  </span>
                  <span *ngIf="!tutor.tiene_fcm_token" class="text-red-500 text-xs">⚠️ Sin FCM</span>
                  <span *ngIf="tutor.tiene_fcm_token" class="text-green-500 text-xs">📱</span>
                </span>
              </label>
            </div>
          </div>
        </div>

        <p class="text-sm text-gray-600 mt-2">
          Seleccionados: <strong>{{destinatariosSeleccionados.length}}</strong> destinatarios
        </p>
      </div>

      <!-- Formulario de notificación -->
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Título *</label>
          <input 
            type="text" 
            [(ngModel)]="notificacion.titulo"
            placeholder="Ingrese el título de la notificación"
            class="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            maxlength="100">
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Mensaje *</label>
          <textarea 
            [(ngModel)]="notificacion.mensaje"
            placeholder="Escriba el mensaje de la notificación"
            rows="4"
            class="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            maxlength="500"></textarea>
          <p class="text-xs text-gray-500 mt-1">{{getMensajeLength()}}/500 caracteres</p>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Tipo</label>
          <select 
            [(ngModel)]="notificacion.tipo"
            class="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500">
            <option value="general">📢 General</option>
            <option value="tarea">📝 Tarea</option>
            <option value="examen">📊 Examen</option>
            <option value="evento">📅 Evento</option>
            <option value="urgente">🚨 Urgente</option>
          </select>
        </div>
      </div>

      <!-- Botones de acción -->
      <div class="flex gap-3 mt-6">
        <button 
          (click)="enviarNotificacion()"
          [disabled]="!puedeEnviar() || enviando"
          class="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed">
          <span *ngIf="!enviando">📤 Enviar Notificación</span>
          <span *ngIf="enviando">⏳ Enviando...</span>
        </button>
        
        <button 
          (click)="limpiarFormulario()"
          class="px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50">
          🗑️ Limpiar
        </button>
      </div>

      <!-- Resultados del envío -->
      <div *ngIf="resultadoEnvio" class="mt-4 p-4 rounded-md" 
           [ngClass]="{
             'bg-green-50 border border-green-200': resultadoEnvio.success,
             'bg-red-50 border border-red-200': !resultadoEnvio.success
           }">
        <h4 class="font-medium mb-2" 
            [ngClass]="{
              'text-green-800': resultadoEnvio.success,
              'text-red-800': !resultadoEnvio.success
            }">
          {{resultadoEnvio.success ? '✅ Notificación Enviada' : '❌ Error al Enviar'}}
        </h4>
        
        <div *ngIf="resultadoEnvio.success" class="text-sm text-green-700">
          <p>📊 <strong>Enviadas:</strong> {{resultadoEnvio.enviadas}}</p>
          <p>❌ <strong>Fallidas:</strong> {{resultadoEnvio.fallidas}}</p>
          <p>📱 <strong>Total:</strong> {{resultadoEnvio.total}}</p>
        </div>
        
        <div *ngIf="!resultadoEnvio.success" class="text-sm text-red-700">
          <p>{{resultadoEnvio.error}}</p>
        </div>
      </div>

      <!-- Estado cuando no hay destinatarios -->
      <div *ngIf="sinDestinatarios()" 
           class="text-center py-8 text-gray-500">
        <div class="text-4xl mb-2">👥</div>
        <p>No se encontraron destinatarios para esta materia</p>
      </div>
    </div>
  `
})
export class NotificacionesComponent implements OnInit {
  @Input() materiaPreseleccionada?: string;

  materias: any[] = [];
  selectedMateria: string = '';
  destinatarios: DestinatariosResponse | null = null;
  destinatariosSeleccionados: number[] = [];
  enviando = false;
  resultadoEnvio: any = null;

  notificacion = {
    titulo: '',
    mensaje: '',
    tipo: 'general'
  };

  constructor(private profesorService: ProfesorService) {}

  ngOnInit(): void {
    this.cargarMaterias();
    
    // Si hay una materia preseleccionada, configurarla
    if (this.materiaPreseleccionada) {
      this.selectedMateria = this.materiaPreseleccionada;
    }
    
    this.cargarDestinatarios();
  }

  // 🔥 Métodos auxiliares para manejo seguro de tipos
  getEstudiantes(): Destinatario[] {
    return this.destinatarios?.estudiantes || [];
  }

  getTutores(): Destinatario[] {
    return this.destinatarios?.tutores || [];
  }

  getMensajeLength(): number {
    return this.notificacion.mensaje?.length || 0;
  }

  sinDestinatarios(): boolean {
    return this.destinatarios !== null && 
           this.getEstudiantes().length === 0 && 
           this.getTutores().length === 0;
  }

  isDestinatarioSeleccionado(id: number): boolean {
    return this.destinatariosSeleccionados.includes(id);
  }

  cargarMaterias(): void {
    this.profesorService.getMateriasConCurso().subscribe(
      data => this.materias = data,
      error => console.error('Error cargando materias:', error)
    );
  }

  cargarDestinatarios(): void {
    const detalleMateriaId = this.selectedMateria ? parseInt(this.selectedMateria) : undefined;
    
    this.profesorService.obtenerDestinatarios(detalleMateriaId).subscribe(
      data => {
        this.destinatarios = data;
        this.destinatariosSeleccionados = [];
        console.log('Destinatarios cargados:', data);
      },
      error => {
        console.error('Error cargando destinatarios:', error);
        this.destinatarios = { estudiantes: [], tutores: [] };
      }
    );
  }

  toggleDestinatario(id: number, event: any): void {
    if (event.target.checked) {
      if (!this.destinatariosSeleccionados.includes(id)) {
        this.destinatariosSeleccionados.push(id);
      }
    } else {
      this.destinatariosSeleccionados = this.destinatariosSeleccionados.filter(d => d !== id);
    }
  }

  seleccionarTodos(): void {
    this.destinatariosSeleccionados = [];
    if (this.destinatarios) {
      this.destinatarios.estudiantes.forEach(e => this.destinatariosSeleccionados.push(e.id));
      this.destinatarios.tutores.forEach(t => this.destinatariosSeleccionados.push(t.id));
    }
  }

  deseleccionarTodos(): void {
    this.destinatariosSeleccionados = [];
  }

  seleccionarSoloEstudiantes(): void {
    this.destinatariosSeleccionados = [];
    if (this.destinatarios) {
      this.destinatarios.estudiantes.forEach(e => this.destinatariosSeleccionados.push(e.id));
    }
  }

  seleccionarSoloTutores(): void {
    this.destinatariosSeleccionados = [];
    if (this.destinatarios) {
      this.destinatarios.tutores.forEach(t => this.destinatariosSeleccionados.push(t.id));
    }
  }

  puedeEnviar(): boolean {
    return this.notificacion.titulo.trim() !== '' && 
           this.notificacion.mensaje.trim() !== '' && 
           this.destinatariosSeleccionados.length > 0;
  }

  enviarNotificacion(): void {
    if (!this.puedeEnviar()) return;

    this.enviando = true;
    this.resultadoEnvio = null;

    const data = {
      destinatarios: this.destinatariosSeleccionados,
      titulo: this.notificacion.titulo.trim(),
      mensaje: this.notificacion.mensaje.trim(),
      tipo: this.notificacion.tipo
    };

    this.profesorService.enviarNotificacionMasiva(data).subscribe(
      response => {
        this.resultadoEnvio = { success: true, ...response };
        this.limpiarFormulario();
        this.enviando = false;
        console.log('Notificación enviada:', response);
      },
      error => {
        this.resultadoEnvio = { 
          success: false, 
          error: error.error?.error || 'Error desconocido al enviar notificación'
        };
        this.enviando = false;
        console.error('Error enviando notificación:', error);
      }
    );
  }

  limpiarFormulario(): void {
    this.notificacion = {
      titulo: '',
      mensaje: '',
      tipo: 'general'
    };
    this.destinatariosSeleccionados = [];
    this.resultadoEnvio = null;
  }
}