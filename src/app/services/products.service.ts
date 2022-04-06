import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http';
import { FormGroup } from "@angular/forms";


@Injectable({
  providedIn: 'root'
})
export class ProductsService {
  constructor(private http: HttpClient) { }

  // https://www.positronx.io/how-to-use-angular-8-httpclient-to-post-formdata/ --> Como subir archivos

  importStudent(form: FormGroup): Observable<any> {
    var formData: any = new FormData();
    formData.append("file", form.get('file').value);
    return this.http.post<any>('http://localhost:3000/student/importstudent', formData);
  }

  addCategorieToProduct(productsIds: string, categoriesIds: string) {
    const body = { productosIDs: productsIds,  categoriasIDs: categoriesIds};
    this.http.put<any>('http://localhost:3000/furniture/addtocategorie', body).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  removeCategorieFromProduct(productsIds: string, categoriesIds: string) {
    const options = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json'}),
      body : { productosIDs: productsIds,  categoriasIDs: categoriesIds}
    };
    return this.http.delete<any>('http://localhost:3000/furniture/removefromcategorie', options).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  addFeatureToProduct(productsIds: string, featuresIds: string) {
    const body = { productosIDs: productsIds,  caracteristicasIDs: featuresIds};
    this.http.put<any>('http://localhost:3000/furniture/addtofeature', body).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  removeFeatureFromProduct(productsIds: string, featuresIds: string) {
    const options = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json'}),
      body : { productosIDs: productsIds,  caracteristicasIDs: featuresIds}
    };
    return this.http.delete<any>('http://localhost:3000/furniture/removefromfeature', options).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  addCareToProduct(productsIds: string, caresIds: string) {
    const body = { productosIDs: productsIds,  cuidadosIDs: caresIds};
    this.http.put<any>('http://localhost:3000/furniture/addtocare', body).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  removeCareFromProduct(productsIds: string, caresIds: string) {
    const options = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json'}),
      body : { productosIDs: productsIds,  cuidadosIDs: caresIds}
    };
    return this.http.delete<any>('http://localhost:3000/furniture/removefromcare', options).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  getProductProfile(productoID: string): Observable<any> {
    const body = { };
    return this.http.post<any>('http://localhost:3000/furniture/profile/' + productoID, body);
  }

  getAllProduct(categories: string, features: string, cares: string): Observable<any> {
    const body = { categoriaID : categories, caracteristicaID: features, cuidadoID: cares };
    return this.http.post<any>('http://localhost:3000/furniture/getall', body);
  }

  updateProduct(productoID: string, name: string, price: number, image: string, quantity: number) {
    const body = { nombre: name,  precio: price, imagen: image, cantidad: quantity};
    this.http.put<any>('http://localhost:3000/furniture/update/' + productoID, body).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  deleteProduct(productId: string) {
    const options = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json'}),
      body : { productoID: productId }
    };
    return this.http.delete<any>('http://localhost:3000/furniture/delete/', options).subscribe(
      (val) => {
        console.log("POST call successful value returned in body",
          val);
      },
      response => {
        console.log("POST call in error", response);
      },
      () => {
        console.log("The POST observable is now completed.");
      });
  }

  addProduct(name: string, price: number, image: string, quantity: number): Observable<any> {
    const body = { nombre: name,  precio: price, imagen: image, cantidad: quantity};
    return this.http.post<any>('http://localhost:3000/furniture/add', body);
  }
}
