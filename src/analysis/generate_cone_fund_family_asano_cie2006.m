% First developed by ACS, modified by TM.
function out = generate_cone_fund_family_asano_cie2006(varargin)
%GENERATE_CONEFUND_FAMILY_ASANOCIE2006
% Family of cone fundamentals using CIE2006/CIEPO06-style components:
% - Age-dependent ocular media density SHAPE via Docul1/Docul2 (Eq 2/3/4 in Asano 2016)
% - Macular pigment via relative density table + field-size dependent peak (Eq 5/6)
% - Cone photopigment absorptance via OD + absorbance shapes (Eq 7/8/9)
%
% NOTE : λmax shifts (sL,sM,sS) are sampled from Normal distributions,
% as assumed in Asano et al. (2016). Default SDs [nm] are Table 5 Step 2:
%   SD(sL)=2.0, SD(sM)=1.5, SD(sS)=1.3, with means = 0.

% -----------------------------
% options
% -----------------------------
p = inputParser;
p.addParameter('data_dir', '.', @(s)ischar(s)||isstring(s));
p.addParameter('N2', 10000, @(x)isnumeric(x)&&isscalar(x)&&x>=1);
p.addParameter('N10', 10000, @(x)isnumeric(x)&&isscalar(x)&&x>=1);
p.addParameter('seed', 0, @(x)isnumeric(x)&&isscalar(x));
p.addParameter('age_range', [18 70], @(x)isnumeric(x)&&numel(x)==2&&x(1)<x(2));

% individual variability (deviations in % for densities)
p.addParameter('sd_dlens_pct', 18.7, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('sd_dmac_pct',  36.5, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('sd_dL_pct',     9.0, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('sd_dM_pct',     9.0, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('sd_dS_pct',     7.4, @(x)isnumeric(x)&&isscalar(x)&&x>=0);

% --- λmax shift distribution (Normal) ---
% Means [nm] (default 0 = no systematic shift relative to the baseline absorbance)
p.addParameter('mu_sL_nm', 0.0, @(x)isnumeric(x)&&isscalar(x));
p.addParameter('mu_sM_nm', 0.0, @(x)isnumeric(x)&&isscalar(x));
p.addParameter('mu_sS_nm', 0.0, @(x)isnumeric(x)&&isscalar(x));
% SDs [nm] (Asano et al. 2016, Table 5 Step 2)
p.addParameter('sd_sL_nm', 2.0, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('sd_sM_nm', 1.5, @(x)isnumeric(x)&&isscalar(x)&&x>=0);
p.addParameter('sd_sS_nm', 1.3, @(x)isnumeric(x)&&isscalar(x)&&x>=0);

% output normalization
p.addParameter('normalize', 'none', @(s)any(strcmpi(s,{'area','max','none'})));

% S-cone long-wave cutoff (match common Asano practice)
p.addParameter('S_cut_nm', 620, @(x)isnumeric(x)&&isscalar(x)&&x>=500&&x<=700);

p.parse(varargin{:});
opt = p.Results;
rng(opt.seed);

data_dir = char(opt.data_dir);

% -----------------------------
% wavelength grids
% -----------------------------
wl_out = (390:5:780)';
wl_in  = (390:5:780)';   % internal grid we interpolate to

% -----------------------------
% load prereceptoral tables (wl + columns) from the consolidated data store
% -----------------------------
data = load_data();
A_mac = data.cie2006_macular_density; A_mac = A_mac(all(~isnan(A_mac),2),:);
A_doc = data.cie2006_docul;           A_doc = A_doc(all(~isnan(A_doc),2),:);
A_abs = data.cie2006_lms_absorbance;  A_abs = A_abs(all(~isnan(A_abs),2),:);

assert(size(A_mac,2) >= 2, 'mac file must be [wl, relMac, ...]');
assert(size(A_abs,2) >= 4, 'abs file must be [wl, L, M, S, ...]');
assert(size(A_doc,2) >= 2, 'docul file must be [wl, Docul...]');

wl_mac = A_mac(:,1); relMac_raw = A_mac(:,2);
wl_doc = A_doc(:,1); doc_cols   = A_doc(:,2:end);
wl_abs = A_abs(:,1);
Labs_raw = A_abs(:,2);
Mabs_raw = A_abs(:,3);
Sabs_raw = A_abs(:,4);

Sabs_raw(Sabs_raw==0) = NaN;

relMac = interp1(wl_mac, relMac_raw, wl_in, 'linear', 'extrap');
relMac = max(relMac, 0);

if size(doc_cols,2) >= 2
    Docul1 = interp1(wl_doc, doc_cols(:,1), wl_in, 'linear', 'extrap');
    Docul2 = interp1(wl_doc, doc_cols(:,2), wl_in, 'linear', 'extrap');
    Docul1 = max(Docul1, 0);
    Docul2 = max(Docul2, 0);
    docMode = "Docul1+Docul2";
else
    Docul  = interp1(wl_doc, doc_cols(:,1), wl_in, 'linear', 'extrap');
    Docul  = max(Docul, 0);
    Docul1 = [];
    Docul2 = [];
    docMode = "DoculDirect";
end

Labs = interp1(wl_abs, Labs_raw, wl_in, 'linear', 'extrap');
Mabs = interp1(wl_abs, Mabs_raw, wl_in, 'linear', 'extrap');
Sabs = interp1(wl_abs, Sabs_raw, wl_in, 'linear', 'extrap');

vals = [Labs(:); Mabs(:); Sabs(:)];
vals = vals(~isnan(vals));
fracNeg = mean(vals < 0);
rangeVals = [prctile(vals,1) prctile(vals,99)];
isLog10 = (fracNeg > 0.5) || (rangeVals(2) <= 2 && rangeVals(1) < 0);

if isLog10
    Labs_lin = 10.^Labs;
    Mabs_lin = 10.^Mabs;
    Sabs_lin = 10.^Sabs;
else
    Labs_lin = Labs;
    Mabs_lin = Mabs;
    Sabs_lin = Sabs;
end

Labs_lin(Labs_lin < 0) = 0;
Mabs_lin(Mabs_lin < 0) = 0;
Sabs_lin(Sabs_lin < 0) = 0;

% -----------------------------
% generate for each field
% -----------------------------
[fund2,  meta2]  = generate_one_field(2,  opt.N2,  opt, wl_in, wl_out, relMac, docMode, Labs_lin, Mabs_lin, Sabs_lin, Docul1, Docul2);
[fund10, meta10] = generate_one_field(10, opt.N10, opt, wl_in, wl_out, relMac, docMode, Labs_lin, Mabs_lin, Sabs_lin, Docul1, Docul2);

% -----------------------------
% pack : merge 2deg + 10deg into one fund/meta
% -----------------------------
out = struct();
out.wl_out = wl_out(:)';                     % 1 x 31
out.fund   = cat(1, fund2, fund10);          % (N2+N10) x 31 x 3
out.meta   = [meta2; meta10];                % (N2+N10) x (...)
out.meta.obs_idx = (1:height(out.meta))';    % stable row id
out.N2  = opt.N2;
out.N10 = opt.N10;

% ======================================================================
function [fund, meta] = generate_one_field(vdeg, N, opt, wl_in, wl_out, relMac, docMode, Labs_lin, Mabs_lin, Sabs_lin, Docul1, Docul2)

    age = randi([opt.age_range(1), opt.age_range(2)], N, 1);

    dlens = opt.sd_dlens_pct * randn(N,1);
    dmac  = opt.sd_dmac_pct  * randn(N,1);
    dL    = opt.sd_dL_pct    * randn(N,1);
    dM    = opt.sd_dM_pct    * randn(N,1);
    dS    = opt.sd_dS_pct    * randn(N,1);

    % --- λmax shifts ~ Normal(mean, sd) ---
    sL_nm = opt.mu_sL_nm + opt.sd_sL_nm * randn(N,1);
    sM_nm = opt.mu_sM_nm + opt.sd_sM_nm * randn(N,1);
    sS_nm = opt.mu_sS_nm + opt.sd_sS_nm * randn(N,1);

    Dmac_max = 0.485 * exp(-vdeg/6.132);
    DLM_max  = 0.38  + 0.54 * exp(-vdeg/1.333);
    DS_max   = 0.30  + 0.45 * exp(-vdeg/1.333);

    fund = zeros(N, numel(wl_out), 3);

    for i = 1:N
        if docMode=="Docul1+Docul2"
            Docul_ave = ocular_density_age(age(i), Docul1, Docul2);
            Docul_i = Docul_ave .* (1 + dlens(i)/100);
        else
            Docul_i = Docul .* (1 + dlens(i)/100);
        end

        Dmac_i = (Dmac_max * (1 + dmac(i)/100)) .* relMac;

        Lshape = shift_spectrum_allowNaN(wl_in, Labs_lin, sL_nm(i));
        Mshape = shift_spectrum_allowNaN(wl_in, Mabs_lin, sM_nm(i));
        Sshape = shift_spectrum_allowNaN(wl_in, Sabs_lin, sS_nm(i));
        Sshape(wl_in >= opt.S_cut_nm) = 0;

        dL_i = max(0, DLM_max * (1 + dL(i)/100));
        dM_i = max(0, DLM_max * (1 + dM(i)/100));
        dS_i = max(0, DS_max  * (1 + dS(i)/100));

        aL = 1 - 10.^(-dL_i * Lshape);
        aM = 1 - 10.^(-dM_i * Mshape);
        aS = 1 - 10.^(-dS_i * Sshape);
        aS(wl_in >= opt.S_cut_nm) = 0;

        Tpre = 10.^(-(Docul_i + Dmac_i));

        Lfund = wl_in .* aL .* Tpre;
        Mfund = wl_in .* aM .* Tpre;    
        Sfund = wl_in .* aS .* Tpre;

        fund(i,:,1) = interp1(wl_in, Lfund, wl_out, 'linear', 0);
        fund(i,:,2) = interp1(wl_in, Mfund, wl_out, 'linear', 0);
        fund(i,:,3) = interp1(wl_in, Sfund, wl_out, 'linear', 0);
    end

    % ----------------------------------------------------------
    % Normalization
    %   - 'max' or 'peak1': per-observer, per-cone peak -> 1
    % ----------------------------------------------------------
    switch lower(opt.normalize)
        case 'area'
            for c = 1:3
                % NaN-safe: treat NaNs as 0 for area normalization
                Fc = fund(:,:,c);
                Fc(~isfinite(Fc)) = 0;
                A = trapz(wl_out, Fc, 2);      % N x 1
                A(A<=0 | ~isfinite(A)) = 1;
                fund(:,:,c) = bsxfun(@rdivide, fund(:,:,c), A);
            end

        case {'max','peak1'}
            for c = 1:3
                Fc = fund(:,:,c);  % N x nW

                % NaN-safe peak per observer
                try
                    mx = max(Fc, [], 2, 'omitnan');  % N x 1 (newer MATLAB)
                catch
                    % older MATLAB: replace NaNs then max
                    Fc2 = Fc; Fc2(~isfinite(Fc2)) = -inf;
                    mx  = max(Fc2, [], 2);
                end

                mx(mx<=0 | ~isfinite(mx)) = 1;
                fund(:,:,c) = bsxfun(@rdivide, fund(:,:,c), mx);
            end

        case 'none'
            % do nothing
    end

    meta = table();
    meta.field_deg = repmat(vdeg, N, 1);
    meta.age = age;
    meta.dlens_pct = dlens;
    meta.dmac_pct  = dmac;
    meta.dL_pct = dL;
    meta.dM_pct = dM;
    meta.dS_pct = dS;
    meta.sL_nm = sL_nm;
    meta.sM_nm = sM_nm;
    meta.sS_nm = sS_nm;

    function y = shift_spectrum_allowNaN(wl, x, shift_nm)
        wlq = wl - shift_nm;
        warnState = warning('query','MATLAB:interp1:NaNstrip');
        warning('off','MATLAB:interp1:NaNstrip');
        y = interp1(wl, x, wlq, 'spline');
        warning(warnState.state,'MATLAB:interp1:NaNstrip');
        y(y<0) = 0;
    end
end

end

function Docul_ave = ocular_density_age(age, Docul1, Docul2)
if age <= 60
    Docul_ave = Docul1 .* (1 + 0.02*(age - 32)) + Docul2;
else
    Docul_ave = Docul1 .* (1.56 + 0.0667*(age - 60)) + Docul2;
end
Docul_ave = max(Docul_ave, 0);
end
