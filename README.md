# Report Images

Resizes large images and adds a border around all images:

```
Usage: report_images.sh image_dir [destination]

This will resize and add a border to all images in the :image_dir:. The results
will be saved in :destination: if provided. If a file already exists in :destination:
with the desired name, a new file will be created with an incrementing file name
e.g. file.png exists so file_0.png will be created.

image_dir:   directory path to the images that will be converted
destination: directory where converted images are saved
             if not provided a directory named 'converted_images' will
             be created in the same location as 'images'. If this is not a
             path then it will be used as the name of the created directory.

Examples:
./report_images.sh ~/temp/convert/images  -> Output will be in ~/temp/convert/converted_images
./report_images.sh ~/temp/convert/images test  -> Output will be in ~/temp/convert/test
./report_images.sh ~/temp/convert/images ~/test  -> Output will be in ~/test
```
