import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { environment } from '../../../environments/environment';
@Injectable({
  providedIn: 'root'
})
export class AlumnoService {
  private apiUrl = environment.apiUrl + 'api';

  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    
    if (!token) {
      console.error('No hay token de acceso disponible');
      return new HttpHeaders();
    }
    
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  // 👈 Usar el endpoint existente
  getMateriasPorAlumno(): Observable<any[]> {
    const headers = this.getHeaders();
    return this.http.get<any[]>(`${this.apiUrl}/alumno/materias/`, { headers })
      .pipe(
        catchError(error => {
          console.error('Error al obtener materias del alumno:', error);
          return throwError(() => error);
        })
      );
  }

  // 👈 Usar el endpoint existente en usuarios
  getResumenDashboard(): Observable<any> {
    const headers = this.getHeaders();
    return this.http.get<any>(`${this.apiUrl}/alumno/resumen/`, { headers })
      .pipe(
        catchError(error => {
          console.error('Error al obtener resumen del dashboard:', error);
          return throwError(() => error);
        })
      );
  }

  // 👈 Usar el nuevo endpoint que acabamos de crear
  getDetalleMateriaAlumno(detalleId: number): Observable<any> {
    const headers = this.getHeaders();
    return this.http.get<any>(`${this.apiUrl}/alumno/materia/${detalleId}/detalle`, { headers })
      .pipe(
        tap(data => console.log('Detalle de materia recibido:', data)),
        catchError(error => {
          console.error('Error al obtener detalle de materia:', error);
          return throwError(() => error);
        })
      );
  }
  
  getHistorialMateriasPorAlumno() {
    return this.http.get<any[]>(`${environment.apiUrl}/api/alumno/materias/historial/`)
      .pipe(
        tap(materias => console.log('Historial de materias recibido:', materias)),
        catchError(this.handleError('getHistorialMateriasPorAlumno', []))
      );
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(`Error en ${operation}:`, error);
      return throwError(() => error);
    };
  }

}
