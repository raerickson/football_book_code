# Python Virtual Environments with `venv`

A virtual environment is a self-contained directory that contains a Python installation for a particular version of Python, plus a number of additional packages. It allows you to manage dependencies for different projects separately.

## Installing `venv`

Python 3.3 and later include the `venv` module by default. To create virtual environments, you need to have Python installed on your system.

## Creating a Virtual Environment

1. Open your terminal or command prompt.
2. Navigate to your project directory:
    ```sh
    cd /path/to/your/project
    ```
3. Create a virtual environment by running:
    ```sh
    python3 -m venv .venv
    ```
    This will create a directory named `.venv` in your project directory.
4. Add `.venv` to your `.gitignore` file. 

## Activating the Virtual Environment

- On macOS and Linux:
    ```sh
    source .venv/bin/activate
    ```
- On Windows:
    ```sh
    .venv\scripts\activate
    ```

After activation, your terminal prompt will change to indicate that you are now working inside the virtual environment.

## Installing Packages

With the virtual environment activated, you can now install packages using `pip`:
```sh
pip install package_name
```

For example, to install `requests`:
```sh
pip install requests
```

## Deactivating the Virtual Environment

To deactivate the virtual environment and return to the global Python environment, simply run:
```sh
deactivate
```

## Removing the Virtual Environment

To remove the virtual environment, simply delete the `.venv` directory:
```sh
rm -rf .venv
```
or on Windows:
```sh
rmdir /s /q .venv
```

## Freezing Packages in a Virtual Environment

With the virtual environment activated, you can now freeze the installed packages using `pip`:
```sh
pip freeze > freeze_file_name
```

For example, to create a freeze file `requirements.txt`:
```sh
pip freeze > requirements.txt
```

## Installing Packages from a Freeze File

With the virtual environment activated, you can now install packages from a freeze file using `pip`:
```sh
pip install -r freeze_file_name
```

For example, to install all required packages listed in `requirements.txt`:
```sh
pip freeze > requirements.txt
```

## Summary

Using `venv` to create virtual environments is a best practice for managing dependencies in Python projects. It ensures that each project has its own dependencies, avoiding conflicts between packages.
