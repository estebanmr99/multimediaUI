import { Routes } from '@angular/router';

import { ProductComponent } from '../../pages/products/product.component';
import { ProductProfileComponent } from '../../pages/product-profile/product-profile.component';
import { AuthorizeGuard } from '../../services/authorize-guard.service';

export const AdminLayoutRoutes: Routes = [
    { path: 'products',           component: ProductComponent, canActivate: [AuthorizeGuard] },
    { path: 'product-profile/:id',   component: ProductProfileComponent, canActivate: [AuthorizeGuard] },
];
