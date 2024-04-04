function new_weights = adjustweights(weights)

w=1./weights;
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

new_weights = w;
