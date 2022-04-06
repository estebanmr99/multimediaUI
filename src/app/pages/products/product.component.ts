import { Component, OnInit, ViewChild } from "@angular/core";
import { NgModule } from "@angular/core";
import { MaterialModule } from "../../material/material.module";
import { FormBuilder, FormControl, FormGroup } from "@angular/forms";
import { MatTableDataSource } from "@angular/material/table";
import { MatSort } from "@angular/material/sort";
import { MatPaginator } from "@angular/material/paginator";
import { AttributesService } from "src/app/services/attributes.service";
import { ProductsService } from "src/app/services/products.service";
import { MatDialog } from "@angular/material/dialog";
import { DialogBoxComponent } from "src/app/components/dialog-box/dialog-box.component";
import { DatePipe } from "@angular/common";
import { SelectionModel } from "@angular/cdk/collections";

@NgModule({
  imports: [MaterialModule],
})
@Component({
  selector: "app-maps",
  templateUrl: "./product.component.html",
  styleUrls: ["./product.component.scss"],
  providers: [DatePipe],
})
export class ProductComponent implements OnInit {
  @ViewChild(MatPaginator) paginator: MatPaginator;

  @ViewChild(MatSort) sort: MatSort;

  form: FormGroup;
  panelOpenState = false;

  categories = new FormControl();
  features = new FormControl();
  cares = new FormControl();

  categoriesList: Array<any> = [];
  categoriesFilter = new FormControl();
  featuresList: Array<any> = [];
  featuresFilter = new FormControl();
  caresList: Array<any> = [];
  caresFilter = new FormControl();

  categoriesFilterList: Array<any> = [];
  featuresFilterList: Array<any> = [];
  caresFilterList: Array<any> = [];

  displayedColumns: string[] = [
    "select",
    "name",
    "price",
    "quantity",
  ];

  dataSource = new MatTableDataSource();

  allProductsResult: Array<any> = [];
  selection = new SelectionModel<any>(true, []);

  constructor(
    public dialog: MatDialog,
    private productsService: ProductsService,
    private attributesService: AttributesService,
    public fb: FormBuilder,
  ) {
    this.getAllAttributes();
    this.getAllProducts(null, null, null);

    this.form = this.fb.group({
      file: [null]
    })
  }

  ngOnInit(): void {}

  getAllProducts(categories: string, features: string, cares: string) {
    categories = categories ? categories : "";
    features = features ? features : "";
    cares = cares ? cares : "";

    this.productsService.getAllProduct(categories, features, cares).subscribe(
      (data) => {
        this.allProductsResult = data;
      },
      (error) => {
        this.allProductsResult = [];
        console.log("Error: ", error);
        this.refreshRows();
      },
      () => this.refreshRows()
    );
  }

  getAllAttributes() {
    this.attributesService.getCategories().subscribe(
      (data) => {
        this.categoriesList = data;
        this.categoriesFilterList = data;
      },
      (error) => console.log("Error: ", error)
    );
    this.attributesService.getFeatures().subscribe(
      (data) => {
        this.featuresList = data;
        this.featuresFilterList = data;
      },
      (error) => console.log("Error: ", error)
    );
    this.attributesService.getCares().subscribe(
      (data) => {
        this.caresList = data;
        this.caresFilterList = data;
      },
      (error) => console.log("Error: ", error)
    );
  }

  filterProducts() {
    if (this.categoriesFilter.value != null) {
      var categoriesIds: Array<string> = [];
      this.categoriesFilter.value.forEach((value) => {
        const foundIndex = this.categoriesFilterList.findIndex(
          (x) => x.nombre === value
        );
        categoriesIds.push(this.categoriesFilterList[foundIndex].id);
      });
      var categoriesIdsString = categoriesIds.map(String).join(";");
    } else var categoriesIdsString = "";

    if (this.featuresFilter.value != null) {
      var featuresIds: Array<string> = [];
      this.featuresFilter.value.forEach((value) => {
        const foundIndex = this.featuresFilterList.findIndex(
          (x) => x.nombre === value
        );
        featuresIds.push(this.featuresFilterList[foundIndex].id);
      });
      var featuresIdsString = featuresIds.map(String).join(";");
    } else var featuresIdsString = "";

    if (this.caresFilter.value != null) {
      var caresIds: Array<string> = [];
      this.caresFilter.value.forEach((value) => {
        const foundIndex = this.caresFilterList.findIndex(
          (x) => x.descripcion === value
        );
        caresIds.push(this.caresFilterList[foundIndex].id);
      });
      var caresIdsString = caresIds.map(String).join(";");
    } else var caresIdsString = "";

    this.getAllProducts(categoriesIdsString, featuresIdsString, caresIdsString);
    this.selection = new SelectionModel<any>(true, []);
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
  }

  refreshTable() {
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
  }

  refreshRows() {
    this.dataSource = new MatTableDataSource(this.allProductsResult);
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
  }

  isAllSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.dataSource.data.length;
    return numSelected === numRows;
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle() {
    this.isAllSelected()
      ? this.selection.clear()
      : this.dataSource.data.forEach((row) => this.selection.select(row));
  }

  checkboxLabel(row?: any): string {
    if (!row) {
      return `${this.isAllSelected() ? "select" : "deselect"} all`;
    }
    return `${this.selection.isSelected(row) ? "deselect" : "select"} row ${
      row.id
    }`;
  }

  onCategorie(value: String) {
    if (this.categories.value != null) {
      var categoriesIds: Array<string> = [];
      this.categories.value.forEach((value) => {
        const foundIndex = this.categoriesList.findIndex((x) => x.nombre === value);
        categoriesIds.push(this.categoriesList[foundIndex].id);
      });
      var categorieIdsString = categoriesIds.map(String).join(";");
    } else var categorieIdsString = "";

    var selectProducts: Array<any> = this.selection.selected;

    var productsIds: Array<string> = [];
    selectProducts.forEach((product) => productsIds.push(product.id));

    var productIdsString = productsIds.map(String).join(";");

    if (value == "agregar")
      this.addCategorie(productIdsString, categorieIdsString);

    if (value == "quitar")
      this.removeCategorie(productIdsString, categorieIdsString);
  }

  addCategorie(productsIds: string, categoriesIds: string) {
    this.productsService.addCategorieToProduct(productsIds, categoriesIds);
    this.refreshTable();
    return true;
  }

  removeCategorie(productsIds: string, categoriesIds: string) {
    this.productsService.removeCategorieFromProduct(productsIds, categoriesIds);
    this.refreshRows();
    return true;
  }

  onFeature(value: String) {
    if (this.features.value != null) {
      var featuresIds: Array<string> = [];
      this.features.value.forEach((value) => {
        const foundIndex = this.featuresList.findIndex((x) => x.nombre === value);
        featuresIds.push(this.featuresList[foundIndex].id);
      });
      var featureIdsString = featuresIds.map(String).join(";");
    } else var featureIdsString = "";

    var selectProducts: Array<any> = this.selection.selected;

    var productsIds: Array<string> = [];
    selectProducts.forEach((product) => productsIds.push(product.id));

    var productIdsString = productsIds.map(String).join(";");

    if (value == "agregar")
      this.addFeature(productIdsString, featureIdsString);

    if (value == "quitar")
      this.removeFeature(productIdsString, featureIdsString);
  }

  addFeature(productsIds: string, featuresIds: string) {
    this.productsService.addFeatureToProduct(productsIds, featuresIds);
    this.refreshTable();
    return true;
  }

  removeFeature(productsIds: string, featuresIds: string) {
    this.productsService.removeFeatureFromProduct(productsIds, featuresIds);
    this.refreshRows();
    return true;
  }

  onCare(value: String) {
    if (this.cares.value != null) {
      var caresIds: Array<string> = [];
      this.cares.value.forEach((value) => {
        const foundIndex = this.caresList.findIndex((x) => x.descripcion === value);
        caresIds.push(this.caresList[foundIndex].id);
      });
      var careIdsString = caresIds.map(String).join(";");
    } else var careIdsString = "";

    var selectProducts: Array<any> = this.selection.selected;

    var productsIds: Array<string> = [];
    selectProducts.forEach((product) => productsIds.push(product.id));

    var productIdsString = productsIds.map(String).join(";");

    if (value == "agregar")
      this.addCare(productIdsString, careIdsString);

    if (value == "quitar")
      this.removeCare(productIdsString, careIdsString);
  }

  addCare(productsIds: string, caresIds: string) {
    this.productsService.addCareToProduct(productsIds, caresIds);
    this.refreshTable();
    return true;
  }

  removeCare(productsIds: string, caresIds: string) {
    this.productsService.removeCareFromProduct(productsIds, caresIds);
    this.refreshRows();
    return true;
  }

  openDialog(action, page, obj) {
    obj.action = action;
    obj.page = page;
    const dialogRef = this.dialog.open(DialogBoxComponent, {
      width: "250px",
      data: obj,
    });

    dialogRef.afterClosed().subscribe((result) => {
      if (result.event == "Agregar") {
        this.addRowData(result.data);
      } else if (result.event == "Eliminar") {
        this.deleteRowData(result.data);
      } else if (result.event == "Editar") {
        this.updateRowData(result.data);
      }
    });
  }

  addRowData(result) {
    if (result.price && result.quantity){
      this.productsService
      .addProduct(result.name, result.price, result.image, result.quantity)
      .subscribe(
        (data) => {
          //addStudents solo devuelve el id
          this.allProductsResult.unshift({
            id: data.id,
            nombre: data.nombre,
            precio: data.precio,
            imagen: data.imagen,
            cantidad: data.cantidad
          });
        },
        (error) => console.log("Error: ", error),
        () => this.refreshTable()
      );
    }
  }

  deleteRowData(row_obj) {
    row_obj.forEach((row) => {
      this.productsService.deleteProduct(row.id);
      const foundIndex = this.allProductsResult.findIndex(
        (x) => x.id === row.id
      );
      this.allProductsResult.splice(foundIndex, 1);
    });

    this.selection = new SelectionModel<any>(true, []);
    this.refreshTable();
    return true;
  }

  onDelete(action: string, page: string) {
    var rowsToDelete: Array<any> = this.selection.selected;

    if (rowsToDelete.length != 0) {
      this.openDialog(action, page, rowsToDelete);
    }
  }

  updateRowData(row_obj) {
    this.productsService.updateProduct(row_obj.id, row_obj.name, row_obj.price, row_obj.image, row_obj.quantity);
    const foundIndex = this.allProductsResult.findIndex((x) => x.id === row_obj.id);
    this.allProductsResult[foundIndex].nombre = row_obj.name;
    this.allProductsResult[foundIndex].precio = row_obj.price;
    this.allProductsResult[foundIndex].imagen = row_obj.image;
    this.allProductsResult[foundIndex].cantidad = row_obj.quantity;

    this.refreshTable();
    return true;
  }

  uploadFile(event) {
    const file = (event.target as HTMLInputElement).files[0];

    const reader = new FileReader();
    let byteArray;

    reader.addEventListener("loadend", function () {
      // convert image file to base64 string
      console.log('base64', reader.result);
      // preview.src = reader.result;
      byteArray = convertDataURIToBinary(reader.result);
      console.log('byte array', byteArray);
    }, false);

    if (file) {
      reader.readAsDataURL(file);
    }

    function convertDataURIToBinary(dataURI) {
      var base64Index = dataURI.indexOf(';base64,') + ';base64,'.length;
      var base64 = dataURI.substring(base64Index);
      var raw = window.atob(base64);
      var rawLength = raw.length;
      var array = new Uint8Array(new ArrayBuffer(rawLength));

      for(var i = 0; i < rawLength; i++) {
        array[i] = raw.charCodeAt(i);
      }
      return array;
    }
  }

  // submitForm() {
  //   console.log(this.form.value)
  //   this.studentsService.importStudent(this.form).subscribe(
  //     (response) =>  console.log(response) ,
  //     (error) => console.log(error),
  //     () => {
  //       this.getAllProducts(null, null, null);
  //       this.refreshRows() ;
  //       location.reload();
  //     }

  //   )
  // }
}
