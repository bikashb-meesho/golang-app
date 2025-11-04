pipeline {
    agent any
    
    environment {
        GO_VERSION = '1.23'
        GOPATH = "${WORKSPACE}/go"
        PATH = "${GOPATH}/bin:/usr/local/go/bin:${env.PATH}"
        LIBRARY_REPO = 'github.com/bikashb-meesho/golang-lib'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    env.BRANCH_NAME = env.GIT_BRANCH.replaceAll('origin/', '')
                }
                echo "Building branch: ${env.BRANCH_NAME}"
                echo "Commit: ${env.GIT_COMMIT_SHORT}"
            }
        }
        
        stage('Library Version Check') {
            when {
                branch 'main'
            }
            steps {
                echo 'Validating library version for main branch...'
                sh '''
                    # Check go.mod for library version
                    if grep -q "replace ${LIBRARY_REPO}" go.mod; then
                        echo "❌ ERROR: Main branch cannot use local 'replace' directive for library"
                        echo "Main branch must use a tagged version from the library repository"
                        exit 1
                    fi
                    
                    # Extract library version
                    LIB_VERSION=$(grep "${LIBRARY_REPO}" go.mod | grep -v "replace" | awk '{print $2}')
                    echo "Using library version: ${LIB_VERSION}"
                    
                    # Verify it's a proper semantic version (not a branch or commit)
                    if ! echo "${LIB_VERSION}" | grep -qE '^v[0-9]+\\.[0-9]+\\.[0-9]+'; then
                        echo "❌ ERROR: Main branch must use a tagged semantic version (e.g., v1.0.0)"
                        echo "Current version: ${LIB_VERSION}"
                        exit 1
                    fi
                    
                    echo "✅ Library version validation passed: ${LIB_VERSION}"
                '''
            }
        }
        
        stage('Library Version Check - Feature Branch') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                echo 'Feature branch - allowing flexible library versions...'
                sh '''
                    # Feature branches can use replace directive or development versions
                    if grep -q "replace ${LIBRARY_REPO}" go.mod; then
                        echo "ℹ️  Using local library via replace directive (allowed for feature branches)"
                    else
                        LIB_VERSION=$(grep "${LIBRARY_REPO}" go.mod | grep -v "replace" | awk '{print $2}')
                        echo "Using library version: ${LIB_VERSION}"
                    fi
                '''
            }
        }
        
        stage('Setup Go') {
            steps {
                sh '''
                    go version
                    go env
                '''
            }
        }
        
        stage('Dependencies') {
            steps {
                echo 'Downloading dependencies...'
                sh '''
                    go mod download
                    go mod verify
                    go mod tidy
                    
                    # Check for any changes after tidy
                    if ! git diff --quiet go.mod go.sum; then
                        echo "⚠️  Warning: go.mod or go.sum changed after 'go mod tidy'"
                        git diff go.mod go.sum
                    fi
                '''
            }
        }
        
        stage('Lint & Format Check') {
            steps {
                echo 'Running linters...'
                sh '''
                    # Check formatting
                    if [ -n "$(gofmt -l .)" ]; then
                        echo "The following files are not formatted:"
                        gofmt -l .
                        exit 1
                    fi
                    
                    # Run go vet
                    go vet ./...
                '''
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh '''
                    go test -v -race -coverprofile=coverage.out ./...
                    go tool cover -func=coverage.out
                '''
            }
            post {
                always {
                    sh 'go test -v -race ./... 2>&1 | tee test-results.txt || true'
                    archiveArtifacts artifacts: 'coverage.out,test-results.txt', allowEmptyArchive: true
                }
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application...'
                sh '''
                    mkdir -p bin
                    go build -o bin/api cmd/api/main.go
                    ls -lh bin/
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: 'bin/*', fingerprint: true
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                echo 'Running integration tests...'
                sh '''
                    # Start the application in background
                    ./bin/api &
                    APP_PID=$!
                    echo "Started app with PID: ${APP_PID}"
                    
                    # Wait for app to start
                    sleep 3
                    
                    # Run basic health check
                    if curl -f http://localhost:8080/health; then
                        echo "✅ Health check passed"
                    else
                        echo "❌ Health check failed"
                        kill ${APP_PID} || true
                        exit 1
                    fi
                    
                    # Test user creation
                    RESPONSE=$(curl -s -X POST http://localhost:8080/api/users \
                        -H "Content-Type: application/json" \
                        -d '{"name":"Test User","email":"test@example.com","age":25,"role":"user"}')
                    
                    if echo "${RESPONSE}" | grep -q '"success":true'; then
                        echo "✅ User creation test passed"
                    else
                        echo "❌ User creation test failed"
                        echo "Response: ${RESPONSE}"
                        kill ${APP_PID} || true
                        exit 1
                    fi
                    
                    # Cleanup
                    kill ${APP_PID} || true
                    wait ${APP_PID} 2>/dev/null || true
                '''
            }
        }
        
        stage('Docker Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t golang-app:${GIT_COMMIT_SHORT} .
                    docker tag golang-app:${GIT_COMMIT_SHORT} golang-app:${BRANCH_NAME}
                    
                    if [ "${BRANCH_NAME}" = "main" ]; then
                        docker tag golang-app:${GIT_COMMIT_SHORT} golang-app:latest
                    fi
                    
                    docker images | grep golang-app
                '''
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Deploying to staging environment...'
                sh '''
                    echo "Would deploy to staging here"
                    # Add your staging deployment commands
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                echo 'Deploying to production environment...'
                sh '''
                    echo "Would deploy to production here"
                    # Add your production deployment commands
                '''
            }
        }
    }
    
    post {
        success {
            echo "✅ Build successful for ${env.BRANCH_NAME}"
            script {
                if (env.BRANCH_NAME == 'main') {
                    echo "Main branch validated with proper library version"
                }
            }
        }
        failure {
            echo "❌ Build failed for ${env.BRANCH_NAME}"
        }
        always {
            // Stop any running app instances
            sh 'pkill -f "cmd/api/main.go" || true'
            sh 'fuser -k 8080/tcp || true'
            cleanWs()
        }
    }
}

