Build Android project
---------------------

Docker-Android can be used for building Android project and executing its unit test. This following steps will illustrate how to build Android project:

1. Clone [this sample test project](https://github.com/android/testing-samples).

    ```
    git clone git@github.com:android/testing-samples.git
    ```

2. Build the project

    ```
    docker run -it --rm -v $PWD/testing-samples/ui/espresso/BasicSample:/home/androidusr/tmp -w /home/androidusr/tmp --entrypoint "/bin/bash" budtmo/docker-android:emulator_11.0_v2.0 -c "./gradlew build"
    ```


[<- BACK TO README](../README.md)
