import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': 0.0,
    'imageUrl': '',
  };
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isLoading = true;
      });
      final products = Provider.of<Products>(context, listen: false);
      if (_editedProduct.id != '') {
        await products.updateProduct(_editedProduct.id, _editedProduct);
      } else {
        await products.addProduct(_editedProduct);
      }
    } catch (err) {
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Error occurred'),
                content: Text(err.toString()),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              ));
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productID = ModalRoute.of(context)!.settings.arguments as String;
      var temp = Provider.of<Products>(
        context,
        listen: false,
      ).findById(productID);

      if (temp == null) {
        return;
      }
      _editedProduct = temp;
      _initValues = {
        'title': _editedProduct.title,
        'description': _editedProduct.description,
        'price': _editedProduct.price,
        'imageUrl': _editedProduct.imageUrl,
      };
      _imageUrlController.text = _editedProduct.imageUrl;
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'] as String,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: value as String,
                          id: _editedProduct.id,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Provide a Value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price']!.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          id: _editedProduct.id,
                          description: _editedProduct.description,
                          price: double.parse(value!),
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a Value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0.0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'] as String,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          id: _editedProduct.id,
                          description: value as String,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a Value';
                        }
                        if (value.length < 10) {
                          return 'Atleast 10 characters long';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          )),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _saveForm(),
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                id: _editedProduct.id,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value as String,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
