import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
@Injectable({ providedIn: 'root' })
export class ActividadService {
  private apiUrl = environment.apiUrl+'api';

  constructor(private http: HttpClient) {}

  getActividades(detalleId: number): Observable<any[]> {
    const headers = this.getHeaders();
    return this.http.get<any[]>(`${this.apiUrl}/profesor/materia/${detalleId}/actividades/`, { headers });
  }

  crearActividad(detalleId: number, data: any): Observable<any> {
    const headers = this.getHeaders();
    return this.http.post(`${this.apiUrl}/profesor/materia/${detalleId}/actividades/crear/`, data, { headers });
  }

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }
}
