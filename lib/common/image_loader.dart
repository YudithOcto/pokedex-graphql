import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final BoxShape shape;

  const ImageLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
    this.shape = BoxShape.rectangle,
  });

  bool isValidNetworkImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    // Define a default error widget if none is provided
    Widget defaultErrorWidget = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade300,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: (width != null && height != null)
            ? (width! < height! ? width! / 2 : height! / 2)
            : 24.0,
      ),
    );

    // If imageUrl is null or empty, display the error widget directly
    if (!isValidNetworkImageUrl(imageUrl)) {
      return errorWidget?.call(context, imageUrl ?? '', null) ?? defaultErrorWidget;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget ??
              (context, url, error) {
            return defaultErrorWidget;
          },
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        );
      },
    );
  }
}
