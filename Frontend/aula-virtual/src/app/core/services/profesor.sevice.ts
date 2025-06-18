import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
@Injectable({ providedIn: 'root' })
export class ProfesorService {
  private apiUrl = environment.apiUrl+'api/profesor/materias/';
  private baseUrl = environment.apiUrl+'api';

  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  getMateriasConCurso(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl, { headers: this.getHeaders() });
  }

  getEstudiantesDeMateria(detalleId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/profesor/materia/${detalleId}/estudiantes/`, { headers: this.getHeaders() });
  }

  registrarAsistencia(detalleId: number, asistencias: any[]): Observable<any> {
    return this.http.post(`${this.baseUrl}/profesor/materia/${detalleId}/registrar-asistencia/`, asistencias, { headers: this.getHeaders() });
  }

  obtenerAsistenciaPorFecha(detalleId: number, fecha?: string): Observable<any> {
    let url = `${this.baseUrl}/profesor/materia/${detalleId}/asistencia-por-fecha/`;
    if (fecha) {
      url += `?fecha=${fecha}`;
    }
    return this.http.get<any>(url, { headers: this.getHeaders() });
  }

  obtenerReporteAsistencia(detalleId: number) {
    return this.http.get<any>(`${this.baseUrl}/profesor/materia/${detalleId}/reporte-asistencia/`, { headers: this.getHeaders() });
  }

  // 🔥 NUEVOS MÉTODOS PARA NOTIFICACIONES

  // Obtener destinatarios (estudiantes y tutores)
  obtenerDestinatarios(detalleMateriaId?: number): Observable<any> {
    let url = `${this.baseUrl}/profesor/destinatarios/`;
    if (detalleMateriaId) {
      url += `?detalle_materia_id=${detalleMateriaId}`;
    }
    return this.http.get<any>(url, { headers: this.getHeaders() });
  }

  // Enviar notificación masiva
  enviarNotificacionMasiva(data: {
    destinatarios: number[];
    titulo: string;
    mensaje: string;
    tipo?: string;
  }): Observable<any> {
    return this.http.post(`${this.baseUrl}/profesor/enviar-notificacion/`, data, { headers: this.getHeaders() });
  }

  // Enviar notificación simple a un usuario
  enviarNotificacionSimple(usuarioId: number, data: {
    titulo: string;
    mensaje: string;
    tipo?: string;
  }): Observable<any> {
    return this.http.post(`${this.baseUrl}/notificacion/simple/${usuarioId}/`, data, { headers: this.getHeaders() });
  }
}
