# Hadoop MapReduce with Docker

### 1. Install and Run Docker

Make sure you have [Docker](https://docs.docker.com/desktop/install/windows-install/) installed and running on your system.

### 2. Build and Run the Container

```bash
docker-compose up --build
```

### 3. Connect to the Virtual Machine

#### Using VS Code:

If you're using VS Code (or a similar editor), you can connect to the Docker container:

- Click on the `><` sign at the bottom left.
- Select **Attach to a Running Container**.
- Choose `"/hadoop-container"` from the list.

#### Using the Command Line:

Alternatively, connect to the running container using:

```bash
docker exec -it hadoop-container /bin/bash
```

> You are now inside a Java Virtual Machine. The `javac` compiler is pre-installed, and Hadoop v3.3.6 is configured. You can check the Hadoop report using: `$ hdfs dfsadmin -report`.

### 4. Compile the MapReduce Algorithm in Java

Ensure you are in the `/usr/local/hadoop` directory:

```bash
cd /usr/local/hadoop
javac -classpath $(hadoop classpath) -d . my-java-files/WordCount.java
jar -cvf wordcount.jar -C . .
```

This will compile the `WordCount.java` file and create the `wordcount.jar` file.

### 5. Create an Input Directory in HDFS

```bash
hdfs dfs -mkdir /input
hdfs dfs -put /usr/local/hadoop/my-data/input.txt /input
hdfs dfs -ls /input
```

This uploads the `input.txt` file to the `/input` directory in HDFS.

### 6. Run the WordCount Job

```bash
hadoop jar wordcount.jar WordCount /input /output
```

### 7. Check the Output

After the job finishes, you can check the output:

```bash
hdfs dfs -cat /output/part-r-00000
```

The output should look something like this:

```
Another  1
DBMSs,   1
However, 1
...
will     3
with     1
```

---
