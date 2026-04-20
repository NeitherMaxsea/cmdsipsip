const s="professional-feedback-toast-style",i="professional-feedback-toast",o="professional-feedback-toast-body",f="professional-feedback-toast-success",d="professional-feedback-toast-error",l=()=>{if(typeof document>"u"||document.getElementById(s))return;const e=document.createElement("style");e.id=s,e.textContent=`
    .${i} {
      min-height: 0 !important;
      border-radius: 20px !important;
      border: 1px solid rgba(148, 163, 184, 0.18) !important;
      box-shadow: 0 22px 48px rgba(15, 23, 42, 0.18) !important;
      padding: 0 !important;
      overflow: hidden !important;
    }
    .${f} {
      background: linear-gradient(135deg, #f8fffd 0%, #ecfeff 52%, #f0fdf4 100%) !important;
      border-left: 4px solid #0f766e !important;
    }
    .${d} {
      background: linear-gradient(135deg, #fff7ed 0%, #fff1f2 54%, #ffffff 100%) !important;
      border-left: 4px solid #dc2626 !important;
    }
    .${o} {
      padding: 14px 16px !important;
      white-space: pre-line !important;
      font-size: 13px !important;
      line-height: 1.5 !important;
      font-weight: 700 !important;
      color: #0f172a !important;
      letter-spacing: -0.01em !important;
    }
    .${o}::first-line {
      color: #020617 !important;
    }
  `,document.head.appendChild(e)},m=(e,n,t,a="",p=3600)=>{l();const r=e==null?void 0:e[n];if(typeof r!="function"||!t)return;const c=n==="success"?f:d;r(a?`${t}
${a}`:t,{timeout:p,icon:!1,closeButton:!1,hideProgressBar:!0,toastClassName:[i,c],bodyClassName:o})};export{m as s};
