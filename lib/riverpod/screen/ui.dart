import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view/multiple_product_view.dart';
import '../view/product_view.dart';

// class SingleProduct extends ConsumerStatefulWidget {
//   const SingleProduct({super.key});

//   @override
//   ConsumerState<SingleProduct> createState() => _SingleProductState();
// }

// class _SingleProductState extends ConsumerState<SingleProduct> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch the product when the widget is initialized
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(productviewmodelProvider.notifier).fetchSingleProduct();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Single Product')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Single Product'),
//             Consumer(
//               builder: (context, ref, child) {
//                 final product = ref.watch(productviewmodelProvider);
//                 return product.when(
//                   data: (data) {
//                     return Column(
//                       children: [
//                         Text(data.title ?? 'No title'),
//                         Text(data.description ?? 'No description'),
//                         Text(data.price.toString()),
//                         Image.network(data.thumbnail ?? ''),
//                       ],
//                     );
//                   },
//                   error: (error, stackTrace) {
//                     return Text(error.toString());
//                   },
//                   loading: () {
//                     return const CircularProgressIndicator();
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MultipleProducts extends ConsumerStatefulWidget {
  const MultipleProducts({super.key});

  @override
  ConsumerState<MultipleProducts> createState() => _MultipleProductsState();
}

class _MultipleProductsState extends ConsumerState<MultipleProducts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(multipleproductviewmodelProvider.notifier).fetchMultipleProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(multipleproductviewmodelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Products')),
      body: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 10, offset: const Offset(0, 5))]),
        margin: const EdgeInsets.all(10),
        child: products.when(
          data: (data) {
            return ListView.builder(
              itemBuilder: (context, index) {
                return Card(child: Column(children: [Text(data[index].title ?? 'No title'), Text(data[index].description ?? 'No description'), Text(data[index].price.toString()), Image.network(data[index].thumbnail ?? '')]));
              },
              itemCount: data.length,
            );
          },
          error: (error, stackTrace) {
            return Center(child: Text(error.toString()));
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
