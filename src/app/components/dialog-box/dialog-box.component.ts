//dialog-box.component.ts
import { Component, Inject, Optional } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Base64Binary } from './test';

@Component({
  selector: 'app-dialog-box',
  templateUrl: './dialog-box.component.html',
  styleUrls: ['./dialog-box.component.scss']
})
export class DialogBoxComponent {

  action: string;
  page: string;
  local_data: any;
  imgByteArray: string;
  canClose: boolean;

  constructor(
    public dialogRef: MatDialogRef<DialogBoxComponent>,
    //@Optional() is used to prevent error if no data is passed
    @Optional() @Inject(MAT_DIALOG_DATA) public data: any) {

    if (Array.isArray(data)){
      this.local_data = Array.from(data);
    } else {
      this.local_data = Object.assign({}, data);
    }
    this.action = this.data.action;
    this.page = this.data.page;
    this.imgByteArray = '';
    this.canClose = false;
  }

  uploadFile(event) {
    const file = (event.target as HTMLInputElement).files[0];

    const reader = new FileReader();

    reader.addEventListener("loadend", function () {
      this.imgByteArray = reader.result;
      this.imgByteArray = this.imgByteArray.split(',')[1];
    }.bind(this), false);

    if (file) {
      reader.readAsDataURL(file);
    }
  }

  doAction(){
    this.local_data.image = this.imgByteArray;
    console.log(this.local_data);
    this.canClose = false;
    this.dialogRef.close({event:this.action,data:this.local_data});
    this.canClose = true;
  }

  closeDialog(){
    this.dialogRef.close({event:'Cancelar'});
  }

}
