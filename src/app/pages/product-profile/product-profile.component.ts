import { Component, OnInit, ViewChild } from '@angular/core';
import { NgModule } from '@angular/core';
import { MaterialModule } from '../../material/material.module';
import {FormControl} from '@angular/forms';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { ActivatedRoute } from '@angular/router';
import { SelectionModel } from '@angular/cdk/collections';
import { DialogBoxComponent } from 'src/app/components/dialog-box/dialog-box.component';
import { MatDialog } from '@angular/material/dialog';
import { ProductsService } from "src/app/services/products.service";
import { DomSanitizer } from '@angular/platform-browser';

@NgModule({
  imports: [MaterialModule],
})

@Component({
  selector: 'app-product-profile',
  templateUrl: './product-profile.component.html',
  styleUrls: ['./product-profile.component.scss']
})
export class ProductProfileComponent  {
  @ViewChild(MatPaginator) paginator: MatPaginator;

  @ViewChild(MatSort) sort: MatSort;
  selection = new SelectionModel<any>(true, []);

  productId: string;

  displayedColumns: string[] = [ "name", "price", "quantity" ];
  dataSource = new MatTableDataSource();

  productCategories: Array<any> = [];
  productFeatures:Array<any> = [];
  productCares:Array<any> = [];
  productProfile: any = {};

  editProduct = false;
  tags = new FormControl();
  categories = new FormControl();
  features = new FormControl();
  cares = new FormControl();
  tagsList : Array<any> = [];
  problems: Array<any> = [];

  constructor(
    private _router: ActivatedRoute,
    public dialog: MatDialog,
    private productsService: ProductsService,
    private sanitizer: DomSanitizer,
  ) {
    this.productId = this._router.snapshot.paramMap.get('id');
    this.getProductInfo(this.productId)
   }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
  }

  getProductInfo(id: string){
    this.productsService.getProductProfile(id).subscribe(
      (data) => {
        this.productCategories = data["categorias"];
        this.productFeatures = data["caracteristicas"];
        this.productCares = data["cuidados"];
        this.productProfile = data;
        this.productProfile["imageBase64"] = this.sanitizer.bypassSecurityTrustUrl('data:image/jpeg;base64,' + (this.productProfile.imagen));
        console.log(this.productProfile);
      },
      (error) => console.log("Error: ", error),
      () => {}
    );
  }

  arrayBufferToBase64 (buffer) {
    var binary = '';
    var bytes = new Uint8Array(buffer);
    var len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
        binary += String.fromCharCode( bytes[ i ] );
    }
    return window.btoa(binary);
  }

  openDialog(action, page, obj) {
    obj.action = action;
    obj.page = page;

    const dialogRef = this.dialog.open(DialogBoxComponent, {
      width: "250px",
      data: obj,

    });

    dialogRef.afterClosed().subscribe((result) => {
    if (result.event == "Editar") {
        this.updateRowData(result.data);
      }
    });

  }

  updateRowData(row_obj) {
    this.productsService.updateProduct(row_obj.id, row_obj.name, row_obj.price, row_obj.image, row_obj.quantity);
    this.productProfile.nombre = row_obj.name;
    this.productProfile.precio = row_obj.price;
    this.productProfile.imagen = row_obj.image;
    this.productProfile.cantidad = row_obj.quantity;

    return true;
  }
}
