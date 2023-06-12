function [ new_weights ] = setweights( NSD,TAC )

%From NSD to weights
w=1./NSD;
vv=~isinf(w);
scale_w=max(w(vv));
for i=1:length(w)
    if w(i)<=0 || isnan(w(i))
        w(i)=0;
    end
    if isinf(w(i))
        w(i)=scale_w;
    end
end
%SCALO per il massimo
tempw=w;
[m1, im1]=max(w);
tempw(im1)=0;
m2=max(tempw);
if m2*10<m1
    w(im1)=m2;
end
scale_w=max(w);
w=w./scale_w;


%Correct for negative value
new_weights=w;
i=find(TAC<=0);
if ~isempty(i)
    new_weights(i)=0;
end


