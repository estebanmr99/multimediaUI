import { Injectable, SkipSelf } from '@angular/core';
import { Observable } from 'rxjs';
import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class AttributesService {
  constructor(private http: HttpClient) { }

  getCategories(): Observable<any> {
    return this.http.get<any>('http://localhost:3000/attributes/getcategories');
  }

  getFeatures(): Observable<any> {
    return this.http.get<any>('http://localhost:3000/attributes/getFeatures');
  }

  getCares(): Observable<any> {
    return this.http.get<any>('http://localhost:3000/attributes/getCares');
  }
}
