function fx = svm_predict(test_data, model_svm)
%% test_data does not contain label in the last column
X_train = model_svm.X_train;
sigmax = model_svm.sigmax;
y5 = model_svm.y5;
Cx = model_svm.Cx;
tol = model_svm.tol;
num_of_train = model_svm.num_of_train;

X_test = [X_train;test_data];

all=size(X_test,1);

for i=1:all
    for j=1:num_of_train
        K(i,j)=1/(1+(norm(X_test(i,:)-X_test(j,:)))^2/(sigmax)^2);
    end
end

Kk=K(1:num_of_train,1:num_of_train);
[alpha,bias] = smo(Kk, y5', Cx, tol);
Kxxi=K((num_of_train+1):all,:);
for m=1:(all-num_of_train)
    fx(m,1)=sign((alpha.*Kxxi(m,:))*y5+bias);
end

